import { Box, Group } from "@mantine/core";
import React from "react";
import { colorMutTable, colorsPicker } from "@/components/colors";
import { PlotData } from "@/components/interfaces";

export default function PopulationsHeatmap({dataPlot}: {dataPlot: PlotData[]}) {
	return (
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
	)
}