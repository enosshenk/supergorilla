--
-- SuperGorilla particles module
-- Holds all particle creation and processing functions for SuperGorilla
--

local SGParticles = {}

-- Particle system vars
SGParticles.fireSystems = {}
SGParticles.sparkSystems = {}
SGParticles.debrisSystems = {}
SGParticles.fireSystems2 = {}
SGParticles.bloodExplosionSystems = {}
SGParticles.bloodSystems = {}


-- Particle images
fire = love.graphics.newImage("/images/fire.tga")
spark = love.graphics.newImage("/images/particle.tga")
debris = love.graphics.newImage("/images/fragment.tga")
bloodExplosion = love.graphics.newImage("/images/bloodexplode.tga")
blood = love.graphics.newImage("/images/bloodparticle.tga")

function SGParticles.update(dt)
	for index, system in ipairs(SGParticles.fireSystems) do
		if system:count() >= 8 then
			SGParticles.stopExplosion(index)
			system:start()
			system:update(dt)
		else
			system:start()
			system:update(dt)
		end
	end
	for index, system in ipairs(SGParticles.sparkSystems) do
		if system:count() >= 75 then
			SGParticles.stopExplosion(index)
			system:start()
			system:update(dt)
		else
			system:start()
			system:update(dt)
		end
	end
	for index, system in ipairs(SGParticles.debrisSystems) do
		if system:count() >= 15 then
			SGParticles.stopDebris(index)
			system:start()
			system:update(dt)
		else
			system:start()
			system:update(dt)
		end
	end
	
	for index, system in ipairs(SGParticles.bloodExplosionSystems) do
		if system:count() >= 9 then
			SGParticles.stopGorillaExplosion(index)
			system:start()
			system:update(dt)
		else
			system:start()
			system:update(dt)
		end
	end
	for index, system in ipairs(SGParticles.fireSystems2) do
		if system:count() >= 9 then
			SGParticles.stopGorillaExplosion(index)
			system:start()
			system:update(dt)
		else
			system:start()
			system:update(dt)
		end
	end
	for index, system in ipairs(SGParticles.bloodSystems) do
		if system:count() >= 35 then
			SGParticles.stopGorillaExplosion(index)
			system:start()
			system:update(dt)
		else
			system:start()
			system:update(dt)
		end
	end
end

function SGParticles.stopExplosion(index)
	SGParticles.fireSystems[index]:setEmissionRate(0)
	SGParticles.sparkSystems[index]:setEmissionRate(0)
end

function SGParticles.stopDebris(index)
	SGParticles.debrisSystems[index]:setEmissionRate(0)
end

function SGParticles.stopGorillaExplosion(index)
	SGParticles.fireSystems2[index]:setEmissionRate(0)
	SGParticles.bloodExplosionSystems[index]:setEmissionRate(0)
	SGParticles.bloodSystems[index]:setEmissionRate(0)
end

function SGParticles.newExplosion(x, y)
	-- Fire system
	local fSystem = love.graphics.newParticleSystem(fire, 50)
	fSystem:setEmissionRate          (8)
	fSystem:setLifetime              (1)
	fSystem:setParticleLife          (0.5)
	fSystem:setPosition              (x, y)
	fSystem:setSpread                (math.rad(360))
	fSystem:setSpeed                 (10, 30)
	fSystem:setGravity               (-20)
	fSystem:setRadialAcceleration    (100)
	fSystem:setTangentialAcceleration(10)
	fSystem:setSizes                  (0.5, 2, 1)
	fSystem:setSizeVariation         (0.5)
	fSystem:setSpin                  (-3, 3, 1)
	fSystem:setSpinVariation         (0)
	fSystem:setColors                 (255, 255, 255, 255, 255, 255, 255, 0)
	-- Spark system
	local sSystem = love.graphics.newParticleSystem(spark, 150)
	sSystem:setEmissionRate          (150)
	sSystem:setLifetime              (1)
	sSystem:setParticleLife          (1)
	sSystem:setPosition              (x, y)
	sSystem:setSpread                (math.rad(360))
	sSystem:setSpeed                 (95, 150)
	sSystem:setGravity               (80)
	sSystem:setRadialAcceleration    (150)
	sSystem:setTangentialAcceleration(10)
	sSystem:setSizes                  (1)
	sSystem:setSizeVariation         (2, 1, 0)
	sSystem:setSpin                  (0)
	sSystem:setSpinVariation         (0)
	sSystem:setColors                 (255, 255, 255, 255, 255, 255, 255, 0)
	
	table.insert(SGParticles.fireSystems, fSystem)
	table.insert(SGParticles.sparkSystems, sSystem)
end

function SGParticles.newDebris(x, y)
	-- Debris system
	local dSystem = love.graphics.newParticleSystem(debris, 50)
	dSystem:setEmissionRate          (25)
	dSystem:setLifetime              (0.5)
	dSystem:setParticleLife          (5)
	dSystem:setPosition              (x, y)
	dSystem:setSpread                (math.rad(360))
	dSystem:setSpeed                 (10, 30)
	dSystem:setGravity               (70)
	dSystem:setRadialAcceleration    (10)
	dSystem:setTangentialAcceleration(10)
	dSystem:setSizes                  (2)
	dSystem:setSizeVariation         (0)
	dSystem:setSpin                  (-3, 3, 1)
	dSystem:setSpinVariation         (0)
	dSystem:setColors                 (255, 255, 255, 255)
	
	table.insert(SGParticles.debrisSystems, dSystem)
end

function SGParticles.newGorillaExplosion(x, y)
	-- Fire system
	local fSystem = love.graphics.newParticleSystem(fire, 50)
	fSystem:setEmissionRate          (8)
	fSystem:setLifetime              (1)
	fSystem:setParticleLife          (0.5)
	fSystem:setPosition              (x, y)
	fSystem:setSpread                (math.rad(360))
	fSystem:setSpeed                 (10, 30)
	fSystem:setGravity               (0)
	fSystem:setRadialAcceleration    (100)
	fSystem:setTangentialAcceleration(10)
	fSystem:setSizes                  (0.5, 2, 1)
	fSystem:setSizeVariation         (0.5)
	fSystem:setSpin                  (-3, 3, 1)
	fSystem:setSpinVariation         (0)
	fSystem:setColors                 (255, 255, 255, 255, 255, 255, 255, 0)
	-- blood explosion system
	local bSystem = love.graphics.newParticleSystem(bloodExplosion, 50)
	bSystem:setEmissionRate          (8)
	bSystem:setLifetime              (1)
	bSystem:setParticleLife          (0.5)
	bSystem:setPosition              (x, y)
	bSystem:setSpread                (math.rad(360))
	bSystem:setSpeed                 (10, 30)
	bSystem:setGravity               (50)
	bSystem:setRadialAcceleration    (100)
	bSystem:setTangentialAcceleration(10)
	bSystem:setSizes                  (0.5, 2, 1)
	bSystem:setSizeVariation         (0.5)
	bSystem:setSpin                  (-3, 3, 1)
	bSystem:setSpinVariation         (0)
	bSystem:setColors                 (255, 255, 255, 255, 255, 255, 255, 0)
	-- Blood drop system
	local sSystem = love.graphics.newParticleSystem(blood, 250)
	sSystem:setEmissionRate          (250)
	sSystem:setLifetime              (1)
	sSystem:setParticleLife          (5)
	sSystem:setPosition              (x, y)
	sSystem:setSpread                (math.rad(360))
	sSystem:setSpeed                 (40, 70)
	sSystem:setGravity               (120)
	sSystem:setRadialAcceleration    (30)
	sSystem:setTangentialAcceleration(40)
	sSystem:setSizes                  (1)
	sSystem:setSizeVariation         (2, 1, 0)
	sSystem:setSpin                  (0)
	sSystem:setSpinVariation         (0)
	sSystem:setColors                 (255, 255, 255, 255, 255, 255, 255, 0)
	
	table.insert(SGParticles.fireSystems2, fSystem)
	table.insert(SGParticles.bloodExplosionSystems, bSystem)
	table.insert(SGParticles.bloodSystems, sSystem)
end

function SGParticles.clearParticles()
	-- Removes all particle systems from the particle tables
	for index, value in ipairs(SGParticles.fireSystems) do
		table.remove(SGParticles.fireSystems, index)
	end
	for index, value in ipairs(SGParticles.sparkSystems) do
		table.remove(SGParticles.sparkSystems, index)
	end
	for index, value in ipairs(SGParticles.debrisSystems) do
		table.remove(SGParticles.debrisSystems, index)
	end
	for index, value in ipairs(SGParticles.fireSystems2) do
		table.remove(SGParticles.fireSystems2, index)
	end
	for index, value in ipairs(SGParticles.bloodExplosionSystems) do
		table.remove(SGParticles.bloodExplosionSystems, index)
	end
	for index, value in ipairs(SGParticles.bloodSystems) do
		table.remove(SGParticles.bloodSystems, index)
	end
end

return SGParticles