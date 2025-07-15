import { BarChart } from "@mantine/charts";
import { Button, Card, Container, Grid, GridCol, Group, SimpleGrid, Stack, Switch, Text } from "@mantine/core";
import PopulationsHeatmap from "./charts/populations-heatmap";
import { useSequencingStore } from "@/lib/sequencing-store";
import Image from "next/image";
import SequencingTable from "./charts/sequencing-table";
import { colorsAddButtonIcon, colorsPage, colorsRunButton } from "./colors";
import { useState } from "react";
import VCFTable from "./vcf-table";
import InnerImageZoom from "react-inner-image-zoom";
import 'react-inner-image-zoom/lib/styles.min.css';

export default function SequencingSection() {
	const { dataPlot, dataPlotStacked, series, sequencingDay, firstSubsampled, plotVersion, numSeq, updateSubsampleVersion, setFirstSubsampled, subsampleVersion, setVCFObjects, subsampled, setSubsampled } = useSequencingStore()
	const [colored, setColored] = useState(false);
	const [loading, setLoading] = useState(false)

	const sequencingSubsample = async () => {
		setSubsampled(false)
		setLoading(true)
		var subsample: any
		if (firstSubsampled) {
			subsample = await fetch(`/api/get_sequencing_subsample?numSeq=${numSeq}`, {
				method: 'GET',
				headers: {
					'Content-Type': 'application/json',
				}
			})
		} else {
			subsample = await fetch(`/api/get_sequencing_subsample?numSeq=${numSeq}&first=false`, {
				method: 'GET',
				headers: {
					'Content-Type': 'application/json',
				}
			})
		}

		const data = await subsample.json();
		setVCFObjects(data['data'])
		updateSubsampleVersion()
		setSubsampled(true)
		setLoading(false)
		setFirstSubsampled(false)
	}

	return (
		<Card mt={"lg"} shadow="sm"
			padding="xl">
			<h2>Sequencing at day {sequencingDay}</h2>
			<Text c={colorsPage.lightDescription} mb={"lg"}>
				This is a zoomed view of the composition of the mass at day {sequencingDay}. At the bottom you can realize a realistic sequencing that randomly subsample the mass, performs a PCR and produce a VCF
			</Text>


			<Container>
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
						<InnerImageZoom
							src={`/api/image_tree?v=${plotVersion}`}
							zoomSrc={`/api/image_tree?v=${plotVersion}`}
							width={400}
							height={350}
							zoomType="hover"
							zoomPreload={true}
						/>
					</Stack>
					<Stack>
						<Grid align="center">
							<GridCol span={6}>
								<Text>
									Variant prevalence histogram
								</Text>
							</GridCol>
							<GridCol span={"auto"}>
								<Switch
									color={colorsAddButtonIcon}
									checked={colored}
									onChange={(event) => setColored(event.currentTarget.checked)}
								/>
							</GridCol>
						</Grid>
						<InnerImageZoom
							src={`/api/histogram?colored=${colored}&v=${plotVersion}`}
							zoomSrc={`/api/histogram?colored=${colored}&v=${plotVersion}`}
							width={400}
							height={350}
							zoomType="hover"
							zoomPreload={true}
						/>
					</Stack>
				</SimpleGrid>
				<Group justify="center" mt={"xl"}>
					<Button onClick={sequencingSubsample} loading={loading} color={colorsRunButton}>Randomly subsample</Button>
				</Group>
				{subsampled && !loading && (
					<Grid mt={"lg"} justify="center" align="center">
						<GridCol span={6}>
							<Image
								key={subsampleVersion}
								src={`/api/zoom_sequence?v=${subsampleVersion}`}
								alt=""
								height={350}
								width={400}
							/>
						</GridCol>
						<GridCol span={6}>
							<div>
								<VCFTable />
							</div>
						</GridCol>
					</Grid>
				)}
			</Container>
		</Card>
	)
}