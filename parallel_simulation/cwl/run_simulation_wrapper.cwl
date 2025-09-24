#!usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  MultipleInputFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  simulation_number: int[]
  simulation_params: File
  seed: int

outputs: 
#   simulation_output:
#     type: Directory[]
#     outputSource: run_simulation/simulation_results
  info_file_output:
    type: File
    outputSource: create_info_file/info_file
  tar_file_output:
    type: File
    outputSource: tar_results/tar_file

steps:
  create_info_file:
    run:
      class: CommandLineTool
      cwlVersion: v1.2
      baseCommand: [bash, -c]
      inputs:
        simulation_params:
          type: File
        seed:
          type: int
      outputs:
        info_file:
          type: File
          outputBinding:
            glob: info.txt
      arguments:
        - valueFrom: |
            echo "$(inputs.simulation_params.basename)_$(inputs.seed)" > info.txt
    in:
      simulation_params: simulation_params
      seed: seed
    out: [info_file]
  run_simulation:
    run: run_simulation.cwl
    scatter: [simulation_number]
    in:
      simulation_number: simulation_number
      simulation_params: simulation_params
      seed: seed
    out: [simulation_results]
  tar_results:
    run:
      class: CommandLineTool
      cwlVersion: v1.2
      baseCommand: [tar, --dereference, -czf]
      inputs:
        tar_name:
          type: string
          inputBinding:
            position: 2
        results:
          type: Directory[]
          inputBinding:
            position: 3
            valueFrom: ${ 
              return self.flatMap(dir => {
                const p = dir.location.replace('file://','');
                const parent = p.substring(0, p.lastIndexOf('/'));
                const name = p.substring(p.lastIndexOf('/') + 1);
                return ['-C', parent, name];
              });
              }
        simulation_params:
          type: File
      outputs:
        tar_file:
          type: File
          outputBinding:
            glob: $(inputs.tar_name)
    in:
      tar_name:
        valueFrom: $(inputs.simulation_params.basename.split('.')[0] + ".tar.gz")
      simulation_params: simulation_params
      results: run_simulation/simulation_results
    out: [tar_file]
