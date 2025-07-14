import { Table } from "@mantine/core";

export default function VCFTable() {

	const elements = [{ "fun_eff": "Growth1", "sample_DP": 127, "sample_AD": 65, "VAF": 0.5118, "mut": "Mut1" }]

	const rows = elements.map((element) => (
		<Table.Tr key={element.mut}>
			<Table.Td>{element.mut}</Table.Td>
			<Table.Td>{element.sample_DP}</Table.Td>
			<Table.Td>{element.sample_AD}</Table.Td>
			<Table.Td>{element.VAF}</Table.Td>
			<Table.Td>{element.fun_eff}</Table.Td>
		</Table.Tr>
	));
	return (
		<Table highlightOnHover withColumnBorders>
			<Table.Thead>
				<Table.Tr style={{backgroundColor: 'black', color: 'white'}}>
					<Table.Th colSpan={5} style={{ textAlign: "center", fontWeight: "bold", fontSize: "1.2rem" }}>
						VCF
					</Table.Th>
				</Table.Tr>
				<Table.Tr>
					<Table.Th>mut</Table.Th>
					<Table.Th>DP</Table.Th>
					<Table.Th>AD_ALT</Table.Th>
					<Table.Th>VAF</Table.Th>
					<Table.Th>functional effect</Table.Th>
				</Table.Tr>
			</Table.Thead>
			<Table.Tbody>{rows}</Table.Tbody>
		</Table>
	)
}