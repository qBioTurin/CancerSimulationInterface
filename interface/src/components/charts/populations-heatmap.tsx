import { Box, Group } from "@mantine/core";
import React from "react";
import { colorMutTable, colorsPicker } from "@/components/colors";
import { PlotData } from "@/components/interfaces";
import InputLabel from "../input-label";
import { useSequencingStore } from "@/lib/sequencing-store";

export default function PopulationsHeatmap() {
	const { dataPlot } = useSequencingStore()
	return (
		<>
			<InputLabel size="md" fw={400} label="Populations colored by number of acquired mutations" tooltip="Each square represents a population. Be aware that the size of the populations are not taken into account here" />
			<Group gap={2} wrap="wrap" w={"100%"}>
				{dataPlot.map((e, idx) => (
					<React.Fragment key={idx}>
						{Array.from({ length: e.nPop }).map((_, i) => (
							<Box
								key={i}
								w={8}
								h={8}
								bg={colorMutTable[idx]}
								style={{ borderRadius: 1 }}
							/>
						))}
					</React.Fragment>
				))}
			</Group>
		</>
	)
}