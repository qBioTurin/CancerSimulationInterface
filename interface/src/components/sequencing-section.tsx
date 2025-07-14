import { BarChart } from "@mantine/charts";
import { Card, Center, SimpleGrid, Stack, Text } from "@mantine/core";
import PopulationsHeatmap from "./charts/populations-heatmap";
import { useSequencingStore } from "@/lib/sequencing-store";
import Image from "next/image";
import { useSimulationPlotOptionsStore } from "@/lib/simulation-plot-options";
import SequencingTable from "./charts/sequencing-table";
import { colorsPage } from "./colors";

export default function SequencingSection() {
	const { dataPlot, dataPlotStacked, series, sequencingDay, plotVersion } = useSequencingStore()

	return (
		<Card mt={"lg"} shadow="sm"
			padding="xl">
			<h2>Sequencing at day {sequencingDay}</h2>
			<Text c={colorsPage.lightDescription} mb={"lg"}>
				This is a zoomed view of the composition of the mass at day {sequencingDay}. At the bottom you can realize a realistic sequencing that randomly subsample the mass, performs a PCR and produce a VCF
			</Text>



			<SequencingTable />
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
			/>
			<Text mt={"lg"}>
				Populations colored by number of acquired mutations
			</Text>
			<PopulationsHeatmap dataPlot={dataPlot} />
			<SimpleGrid cols={2} mt={"lg"}>
				<Stack>
					<Text>
						Evolutionary tree
					</Text>
					<Image
						key={plotVersion}
						src={`/api/image_tree?v=${plotVersion}`}
						alt="Tree"
						height={350}
						width={400}
					/>
				</Stack>
				<Stack>
					<Text >
						Variant prevalence histogram
					</Text>
				</Stack>
			</SimpleGrid>
		</Card>
	)
}