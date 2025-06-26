import { create } from "zustand";

interface Color {
	color: string;
	label: string;
}

interface ColorsLegend {
	colors: Color[];
	changeColor: number;
	changingColor: boolean;

	addColor: (color: Color) => void;
	updateColorByLabel: (label: string, newColor: string) => void;
	resetColors: () => void;

	updateChangeColor: () => void;
	updateChangingColor: () => void;
}

export const useColorsLegendStore = create<ColorsLegend>((set) => ({
	colors: [],
	changeColor: 0,
	changingColor: false,

	addColor: (color) => {
		set(state => ({
			colors: [...state.colors, color]
		}))
	},
	updateColorByLabel: (label, newColor) => {
		set(state => ({
			colors: state.colors.map((c) =>
				c.label === label ? { ...c, color: newColor } : c
			)
		}))
	},
	resetColors: () => {
		set(() => ({
			colors: []
		}))
	},
	updateChangeColor: () => {
		set((state) => ({
			changeColor: state.changeColor + 1
		}))
	},
	updateChangingColor: () => {
		set((state) => ({
			changingColor: !state.changingColor
		}))
	}
}));
