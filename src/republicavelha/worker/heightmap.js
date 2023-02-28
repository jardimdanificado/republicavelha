"use strict";

const randomInRange = function (min, max) 
{ 
	return Math.floor(Math.random() * (max - min + 1) + min); 
}

function Heightmap(size) 
{
	const N = (8+randomInRange(0,5));
	const RANDOM_INITIAL_RANGE = (10+randomInRange(0,3));
	var MATRIX_LENGTH = Math.pow(2, N)+1;

	const generateMatrix = function() {
		const matrix = new Array(MATRIX_LENGTH)
			.fill(0)
			.map(() => new Array(MATRIX_LENGTH).fill(null));

		matrix[0][MATRIX_LENGTH - 1] = randomInRange(0, RANDOM_INITIAL_RANGE);
		matrix[MATRIX_LENGTH - 1][0] = randomInRange(0, RANDOM_INITIAL_RANGE);
		matrix[0][0] = randomInRange(0, RANDOM_INITIAL_RANGE);
		matrix[MATRIX_LENGTH - 1][MATRIX_LENGTH - 1] = randomInRange(
			0,
			RANDOM_INITIAL_RANGE
		);

		return matrix;
	}

	const calculateSquare = function(matrix, chunkSize, randomFactor) 
	{
		let sumComponents = 0;
		let sum = 0;
		for (let i = 0; i < matrix.length - 1; i += chunkSize) 
		{
			for (let j = 0; j < matrix.length - 1; j += chunkSize) 
			{
				const BOTTOM_RIGHT = matrix[j + chunkSize]
					? matrix[j + chunkSize][i + chunkSize]
					: null;
				const BOTTOM_LEFT = matrix[j + chunkSize]
					? matrix[j + chunkSize][i]
					: null;
				const TOP_LEFT = matrix[j][i];
				const TOP_RIGHT = matrix[j][i + chunkSize];
				const { count, sum } = [
					BOTTOM_RIGHT,
					BOTTOM_LEFT,
					TOP_LEFT,
					TOP_RIGHT
				].reduce(
					(result, value) => 
					{
						if (isFinite(value) && value != null) 
						{
							result.sum += value;
							result.count += 1;
						}
						return result;
					},
					{ sum: 0, count: 0 }
				);
				matrix[j + chunkSize / 2][i + chunkSize / 2] =
					sum / count + randomInRange(-randomFactor, randomFactor);
			}
		}
	}

	const calculateDiamond = function(matrix, chunkSize, randomFactor) 
	{
		const half = chunkSize / 2;
		for (let y = 0; y < matrix.length; y += half) {
			for (let x = (y + half) % chunkSize; x < matrix.length; x += chunkSize) 
			{
				const BOTTOM = matrix[y + half] ? matrix[y + half][x] : null;
				const LEFT = matrix[y][x - half];
				const TOP = matrix[y - half] ? matrix[y - half][x] : null;
				const RIGHT = matrix[y][x + half];
				const { count, sum } = [BOTTOM, LEFT, TOP, RIGHT].reduce(
					(result, value) => 
					{
						if (isFinite(value) && value != null) 
						{
							result.sum += value;
							result.count += 1;
						}
						return result;
					},
					{ sum: 0, count: 0 }
				);
				matrix[y][x] = sum / count + randomInRange(-randomFactor, randomFactor);
			}
		}
		return matrix;
	}

	const diamondSquare = function(matrix) 
	{
		let chunkSize = MATRIX_LENGTH - 1;
		let randomFactor = RANDOM_INITIAL_RANGE;

		while (chunkSize > 1) 
		{
			calculateSquare(matrix, chunkSize, randomFactor);
			calculateDiamond(matrix, chunkSize, randomFactor);
			chunkSize /= 2;
			randomFactor /= 2;
		}

		return matrix;
	}

	const normalizeMatrix = function(matrix) 
	{
		const maxValue = matrix.reduce((max, row) => 
		{
			return row.reduce((max, value) => Math.max(value, max));
		}, -Infinity);

		return matrix.map((row) => 
		{
			return row.map((val) => val / maxValue);
		});
	}
	
	if (typeof size != 'undefined')
		MATRIX_LENGTH = size + 1;
	
	return (normalizeMatrix(diamondSquare(generateMatrix())));
}

onmessage = function(event) 
{
	postMessage(Heightmap(event.data));
	self.close();
};