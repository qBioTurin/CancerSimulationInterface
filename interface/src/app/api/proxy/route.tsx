import { NextResponse } from 'next/server';

export async function POST(req: Request) {
	const body = await req.json();

	await fetch('http://simulator:5000/run-r', {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json',
		},
		body: JSON.stringify(body.sim),
	});

	const apiRes=await fetch('http://simulator:5000/get_obs_tum', {
		method: 'GET',
		headers: {
			'Content-Type': 'application/json',
		},
	});

	// const apiRes = await fetch('http://simulator:5000/draw_plot', {
	// 	method: 'POST',
	// 	headers: {
	// 		'Content-Type': 'application/json',
	// 	},
	// 	body: JSON.stringify(body.image),
	// });


	const data = await apiRes.json();

	return NextResponse.json(data);

}
