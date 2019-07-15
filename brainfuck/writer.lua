local function new()

	return
	{
		src = {},

		raw = function(self, s)
			table.insert(self.src, s)
		end,

		next = function(self,n) self:raw ((">"):rep(n or 1)) end,
		prev = function(self,n) self:raw (("<"):rep(n or 1)) end,
		incr = function(self) self:raw "+" end,
		decr = function(self) self:raw "-" end,
		debug = function(self) self:raw "*" end,

		dump = function(self)
			return table.concat(self.src)
		end,

		zero = function(self)
			self:raw "[-]"
		end,

		constant = function(self, n)
			self:zero()
			self:raw(("+"):rep(n))
		end,
		
		-- [a] --> a [a]
		dup = function(self)
			self:raw "[->+>+<<]>>[-<<+>>]<<"
		end,
		
		-- [a] --> 0 * * * [a]
		move = function(self, n)
			self:raw "[-"
			self:next(n)
			self:raw "+"
			self:prev(n)
			self:raw "]"
		end,
		
		-- 0 * * * [a] --> [a] * * * 0
		moveDown = function(self, n)
			self:raw "[-"
			self:prev(n)
			self:raw "+"
			self:next(n)
			self:raw "]"
			self:prev(n)
		end,

		-- a [b] --> [a+b] 0
		add = function(self)
			self:raw "[<+>-]<"
		end,
		
		-- a [b] --> [a-b] 0
		sub = function(self)
			self:raw "[-<->]<"
		end,
		
		-- a [b] --> [a*b] 0
		mul = function(self)
			self:loop()
				self:loop()
					self:raw "+>+<"
				self:endLoop()
				
				self:next(2)
				self:moveDown(2)
			self:endLoop()

			self:next()
			self:zero()
			self:next()
			self:moveDown(2)
		end,
		
		-- [a] * * * --> [0] * * *
		loop = function(self)
			self:raw "[->"
		end,
		
		endLoop = function(self)
			self:raw "<]"
		end,
		
		

	}
end

return
{
	new = new
}