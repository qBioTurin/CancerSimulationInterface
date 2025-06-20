import { useGeneralInformationStore } from "@/lib/general-information-store";
import { Accordion, AccordionControl, Text, AccordionItem, AccordionPanel, Grid, GridCol, Group, NumberInput } from "@mantine/core";

export default function AdvancedInformation() {
	const {
		endingTime,
		savingCheckpoints,
		setEndingTime,
		setSavingCheckpoints
	} = useGeneralInformationStore();

	return (
		<Accordion variant="filled" mt={"md"}>
			<AccordionItem key={'advanced'} value={'advanced'}>
				<AccordionControl>
					<Group justify="flex-end">
						<Text fw={600} mx={"md"}>
							Advanced information
						</Text>
					</Group>
				</AccordionControl>
				<AccordionPanel>
					<Grid align="flex-end" >
						<GridCol span={6}>
							<NumberInput
								label="Ending time of the simulation (days)"
								defaultValue={endingTime}
								hideControls
								onChange={(val) => setEndingTime(Number(val))}
							/>
						</GridCol>
						<GridCol span={6}>
							<NumberInput
								label="Number of saving checkpoint"
								defaultValue={savingCheckpoints}
								hideControls
								onChange={(val) => setSavingCheckpoints(Number(val))}
							/>
						</GridCol>
					</Grid>

				</AccordionPanel>
			</AccordionItem>
		</Accordion>

	);
}