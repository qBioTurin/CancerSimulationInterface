import { useColorsLegendStore } from "./colors-legend-store"

export default function parseColors() {
	const { colors } = useColorsLegendStore.getState()

	const jsonObject = {
		colors
	}

	return jsonObject 
}