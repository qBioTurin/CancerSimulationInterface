import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
	const numSeq = request.nextUrl.searchParams.get('numSeq') as string;
	const first = request.nextUrl.searchParams.get('first') as string;
	const color = request.nextUrl.searchParams.get('color') as string;
	const apiRes = await fetch(`http://simulator:5000/get_sequencing_subsample?numSeq=${numSeq}&first=${first}&color=${color}`, {
		method: 'GET',
		headers: {
			'Content-Type': 'application/json',
		},
	});


	const data = await apiRes.json();

	return NextResponse.json(data);

}
