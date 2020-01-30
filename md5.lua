
function md5(data)
	-- lua 5.3.4
	local get_x = ("<I4"):rep(16)
	
	local t = {[0]=
		0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
		0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
		0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
		0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
		0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
		0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
		0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
		0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
		0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
		0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
		0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
		0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
		0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
		0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
		0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
		0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391,
		0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476
	}
	
	local x = {}
	local a, b, c, d = 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476

	local mask = (1 << 32) - 1
	
	local function rotate_left(x, n)
		return x << n | (mask & x) >> 32 - n  
	end

	local function process_data(data)
		local pos = 1
		
		while pos - 1 <= #data - 64 do
		
			  x[0],  x[1],  x[2],  x[3]
			, x[4],  x[5],  x[6],  x[7]
			, x[8],  x[9],  x[10], x[11]
			, x[12], x[13], x[14], x[15]
			= get_x:unpack(data, pos)

			local aa, bb, cc, dd = a, b, c, d

			for i = 0, 12, 4 do
				a = b + rotate_left(a + (b & c | ~b & d) + x[    i] + t[i    ],  7)
				d = a + rotate_left(d + (a & b | ~a & c) + x[1 + i] + t[i + 1], 12)
				c = d + rotate_left(c + (d & a | ~d & b) + x[2 + i] + t[i + 2], 17)
				b = c + rotate_left(b + (c & d | ~c & a) + x[3 + i] + t[i + 3], 22)
			end

			for i = 0, 12, 4 do
				a = b + rotate_left(a + (b & d | c & ~d) + x[ 1  + i      ] + t[i + 16],  5)
				d = a + rotate_left(d + (a & c | b & ~c) + x[(6  + i) % 16] + t[i + 17],  9)
				c = d + rotate_left(c + (d & b | a & ~b) + x[(11 + i) % 16] + t[i + 18], 14)
				b = c + rotate_left(b + (c & a | d & ~a) + x[      i      ] + t[i + 19], 20)
			end
			
			
			for i = 0, 12, 4 do
				a = b + rotate_left(a + (b ~ c ~ d) + x[(21 - i) % 16] + t[i + 32],  4)
				d = a + rotate_left(d + (a ~ b ~ c) + x[(24 - i) % 16] + t[i + 33], 11)
				c = d + rotate_left(c + (d ~ a ~ b) + x[(27 - i) % 16] + t[i + 34], 16)
				b = c + rotate_left(b + (c ~ d ~ a) + x[ 14 - i      ] + t[i + 35], 23)
			end
			
			for i = 0, 12, 4 do
				a = b + rotate_left(a + (c ~ (b | ~d)) + x[(16 - i) % 16] + t[i + 48],  6)
				d = a + rotate_left(d + (b ~ (a | ~c)) + x[(23 - i) % 16] + t[i + 49], 10)
				c = d + rotate_left(c + (a ~ (d | ~b)) + x[ 14 - i      ] + t[i + 50], 15)
				b = c + rotate_left(b + (d ~ (c | ~a)) + x[(21 - i) % 16] + t[i + 51], 21)
			end

			a = a + aa & mask
			b = b + bb & mask
			c = c + cc & mask
			d = d + dd & mask

			pos = pos + 64
		end
		
		return pos
	end

	local pos = process_data(data)

	process_data(data:sub(pos) .. "\x80" .. ("\0"):rep((64 - (#data + 9) % 64) % 64) .. ("<I8"):pack(#data * 8))

	return ("<I4<I4<I4<I4"):pack(a, b, c, d)
end
