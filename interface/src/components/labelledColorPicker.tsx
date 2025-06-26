'use client'
import { Box, ColorPicker, Group, LoadingOverlay, Popover, PopoverDropdown, PopoverTarget, Text } from "@mantine/core";
import { useState } from "react";
import { colorsPicker } from "./colors";
import { useColorsLegendStore } from "@/lib/colors-legend-store";

export default function LabelledColorPicker({ label, c }: { label: string, c: string }) {
	const [opened, setOpened] = useState(false);
	const [color, setColor] = useState(c);

	const { updateColorByLabel, updateChangeColor, changeColor, changingColor } = useColorsLegendStore()

	return (
		<>
			<Group>
				<Popover opened={opened} onChange={setOpened} position="bottom" withArrow shadow="md">
					<PopoverTarget>
						<Box
							w={32}
							h={32}
							bg={color}
							style={{ borderRadius: 4, cursor: 'pointer' }}
							onClick={() => setOpened((o) => !o)}
						/>
					</PopoverTarget>
					{!changingColor &&
						<PopoverDropdown>
							<ColorPicker value={color} swatchesPerRow={10} onChange={(e) => {
								setColor(e)
								updateColorByLabel(label, e)
								updateChangeColor()
							}} swatches={colorsPicker} />
						</PopoverDropdown>
					}
				</Popover>
				<Text>{label}</Text>
			</Group>
		</>
	)
}