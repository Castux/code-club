importScripts("fengari-webworker.js")

const luaconf  = fengari.luaconf;
const lua      = fengari.lua;
const lauxlib  = fengari.lauxlib;
const lualib   = fengari.lualib;
const interop  = fengari.interop;

var lua_state;

const report = function(L, status)
{
    if (status !== lua.LUA_OK)
    {
        console.log(lua.lua_tojsstring(L, -1) + "\n");
        lua.lua_pop(L, 1);
    }
    return status;
};

const msg_handler = function(L)
{
    let msg = lua.lua_tostring(L, 1);
    if (msg === null)
    {
        if (lauxlib.luaL_callmeta(L, 1, fengari.to_luastring("__tostring")) && lua.lua_type(L, -1) == LUA_TSTRING)
            return 1;
        else
            msg = lua.lua_pushstring(L, fengari.to_luastring(`(error object is a ${fengari.to_jsstring(lauxlib.luaL_typename(L, 1))} value)`));
    }
    lauxlib.luaL_traceback(L, L, msg, 1);
    return 1;
};

const do_call = function(L, narg, nres)
{
    let base = lua.lua_gettop(L) - narg;
    lua.lua_pushcfunction(L, msg_handler);
    lua.lua_insert(L, base);
    let status = lua.lua_pcall(L, narg, nres, base);
    lua.lua_remove(L, base);
    return status;
};

function post_from_lua(L)
{
    var cmd = interop.tojs(L, 1);
    var arg = interop.tojs(L, 2);

    postMessage({'command': cmd, 'arg': arg});

    return 0;
}

function setup()
{
    // Open Lua state

    const L = lauxlib.luaL_newstate();
    lualib.luaL_openlibs(L);
    lauxlib.luaL_requiref(L, "js", interop.luaopen_js, 0);

    lua.lua_atnativeerror(L, (x) => {
        console.log("Native error:");
        console.log(x);
    });

    // Expose "post"

    lua.lua_pushjsfunction(L, post_from_lua);
    lua.lua_setglobal(L, fengari.to_luastring("post_message_internal"));

    // Run worker code

    var status = lauxlib.luaL_loadfile(L, fengari.to_luastring("worker.lua"))
        || do_call(L, 0, 0);
    report(L, status);

    if(status != lua.LUA_OK)
        return;

    addEventListener('message', function(e)
    {
        var data = e.data;

        lua.lua_getglobal(L, "on_message");
        interop.push(L, data.command);
        interop.push(L, data.arg);

        var status = do_call(L, 2, 0);
        report(L, status);
    });
}

setup();
