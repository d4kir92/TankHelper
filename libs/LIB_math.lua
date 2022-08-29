-- LIB Math

function mathR(num, dec)
	dec = dec or 2
	return tonumber(string.format("%." .. dec .. "f", num))
end

function RGBToDec(rgb)
	return mathR(rgb / 255, 2)
end

function NN(value, short)
	value = tonumber(value) or value
	if value > 999999999 then
		if short then
			return format("%.0f B", value / 1000000000)
		end
		return format("%.1f B", value / 1000000000)
	elseif value > 999999 then
		if short then
			return format("%.0f M", value / 1000000)
		end
		return format("%.1f M", value / 1000000)
	elseif value > 999 then
		if short then
			return format("%.0f K", value / 1000)
		end
		return format("%.1f K", value / 1000)
	else
		return value
	end
end