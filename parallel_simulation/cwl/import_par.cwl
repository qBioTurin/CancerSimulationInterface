#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerPull: qbioturin/cancer_simulator:0.0.1

baseCommand: ["Rscript", "/app/scripts/import_par_slurm.R"]

inputs:
  import_json:
    type: File
    inputBinding:
      position: 1
      prefix: --params
  output_dir:
    type: string
    default: "."
    inputBinding:
      position: 2
      prefix: --dir

outputs:
  output_rdata:
    type: File
    outputBinding:
      glob: $(inputs.output_dir)/Parameters.RData
      outputEval: ${
        var nameParts = inputs.import_json.basename.split(".");
        self[0].basename = nameParts[0] + ".RData";
        return self; }