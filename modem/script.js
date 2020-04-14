var encoder;
var bits_per_symbol;
var samples_per_symbol;

function byte_to_symbols(b)
{
    var symbols = [];
    switch(bits_per_symbol)
    {
        case 1:
            symbols.push((b & 0x80) >> 7);
            symbols.push((b & 0x40) >> 6);
            symbols.push((b & 0x20) >> 5);
            symbols.push((b & 0x10) >> 4);
            symbols.push((b & 0x08) >> 3);
            symbols.push((b & 0x04) >> 2);
            symbols.push((b & 0x02) >> 1);
            symbols.push((b & 0x01) >> 0);
            break;
        case 2:
            symbols.push((b & 0xc0) >> 6);
            symbols.push((b & 0x30) >> 4);
            symbols.push((b & 0x0c) >> 2);
            symbols.push((b & 0x03) >> 0);
            break;
        case 4:
            symbols.push((b & 0xf0) >> 4);
            symbols.push((b & 0x0f) >> 0);
            break;
        case 8:
            symbols.push(b);
            break;
    }

    return symbols;
}

function symbols_to_byte(s, index)
{
    var byte = 0;

    switch(bits_per_symbol)
    {
        case 1:
            byte |= s[index + 0] << 7;
            byte |= s[index + 1] << 6;
            byte |= s[index + 2] << 5;
            byte |= s[index + 3] << 4;
            byte |= s[index + 4] << 3;
            byte |= s[index + 5] << 2;
            byte |= s[index + 6] << 1;
            byte |= s[index + 7] << 0;
            break;
        case 2:
            byte |= s[index + 0] << 6;
            byte |= s[index + 1] << 4;
            byte |= s[index + 2] << 2;
            byte |= s[index + 3] << 0;
            break;
        case 4:
            byte |= s[index + 0] << 4;
            byte |= s[index + 1] << 0;
            break;
        case 8:
            byte = s[index];
    }

    return byte;
}

function text_to_symbols(str)
{
    var codes = new TextEncoder().encode(str);
    var symbols = [];

    for(var i = 0 ; i < codes.length ; i++)
    {
        symbols.push(byte_to_symbols(codes[i], bits_per_symbol));
    }

    return symbols.flat();
}

function symbols_to_text(symbols)
{
    var codes = [];

    var symbols_per_byte = 8 / bits_per_symbol;

    for(var i = 0 ; i < symbols.length ; i += symbols_per_byte)
    {
        codes.push(symbols_to_byte(symbols, i, bits_per_symbol));
    }

    return new TextDecoder().decode(Uint8Array.from(codes));
}

function on_input()
{
    var input = document.getElementById("input-line");
    var text = input.value;

    var log = document.getElementById("sent-messages");
    log.value = log.value == "" ? text : log.value + "\n" + text;

    var symbols = text_to_symbols(text, bits_per_symbol);
    var text = symbols_to_text(symbols, bits_per_symbol);

    console.log("Decoded", text);

    encoder.port.postMessage({'cmd': 'symbols', 'data': symbols});

    input.value = null;
}

function update_parameters()
{
    bits_per_symbol = parseInt(document.getElementById("bits-per-symbol").value);
    samples_per_symbol = parseInt(document.getElementById("samples-per-symbol").value);

    encoder.port.postMessage({ 'cmd': 'sps', 'data': samples_per_symbol});
}

function setup()
{
    var context = new AudioContext();
    console.log(context.sampleRate);

    context.audioWorklet.addModule('worklet.js').then( () =>
    {
        encoder = new AudioWorkletNode(context, 'dpsk-encoder', {
            numberOfInputs: 0,
            numberOfOutputs: 1,
            outputChannelCount: [2]
        });
        encoder.connect(context.destination);

        update_parameters();
    });

    var button = document.getElementById("start-button");
    button.parentNode.removeChild(button);

    document.getElementById("container").style.display = "block";
}
