#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerPull: qbioturin/cancer_simulator:0.0.1

baseCommand: ["Rscript", "/app/scripts/run_simulation_slurm.R"]

inputs:
  simulation_number:
    type: int
    inputBinding:
      position: 1
      prefix: --Nexp
  simulation_params:
    type: File
    inputBinding:
      position: 2
      prefix: --params_RData
  seed:
    type: int
    inputBinding:
      position: 3
      prefix: --seed
  output_dir:
    type: string
    default: "."
    inputBinding:
      position: 4
      prefix: --output_dir

outputs:
  simulation_results:
    type: Directory
    outputBinding:
      glob: $(inputs.output_dir)/sim$(inputs.simulation_number)
      outputEval: ${
        var nameParts = inputs.simulation_params.basename.split(".");
        self[0].basename = nameParts[0] + "_sim" + inputs.simulation_number;
        return self; }