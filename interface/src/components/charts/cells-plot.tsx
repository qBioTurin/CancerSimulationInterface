import { useSequencingStore } from "@/lib/sequencing-store";
import { BarChart } from "@mantine/charts";
import { Text } from "@mantine/core";

export default function CellsPlot() {
	const { dataPlotStacked, series } = useSequencingStore()

	return (
		<>
			<Text mt={"lg"}>
				Number of cells colored by number of acquired mutations
			</Text>
			<BarChart
				h={100}
				data={dataPlotStacked}
				tickLine="none"
				gridAxis="none"
				type="percent"
				orientation="vertical"
				dataKey="name"
				withYAxis={false}
				series={series}
				barProps={{ width: 20 }}
				mb={"lg"}
			/>
		</>
	)
}