local _, TankHelper = ...

function TankHelper:MathR(num, dec)
	dec = dec or 2

	return tonumber(string.format("%." .. dec .. "f", num))
end