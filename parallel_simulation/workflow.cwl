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
  simulations_dir: Directory


outputs: 
  info_file_results:
    type: File[]
    outputSource: run_simulation_wrapper/info_file_output
  tar_file_results:
    type: File[]
    outputSource: run_simulation_wrapper/tar_file_output

steps:
  list_files:
    run:
      class: ExpressionTool
      cwlVersion: v1.2
      requirements:
        InlineJavascriptRequirement: {}
        LoadListingRequirement:  
          loadListing: shallow_listing
      inputs:
        dir: Directory
      outputs:
        files:
          type: File[]
      expression: |
        ${
          return { files: inputs.dir.listing.filter(x => x.class === "File") };
        }
    in:
      dir: simulations_dir
    out: [files]
  generate_randoms:
    run:
      class: ExpressionTool
      cwlVersion: v1.2
      requirements:
        InlineJavascriptRequirement: {}
      inputs:
        simulations_params: File[]
      outputs:
        random_numbers:
          type: int[]
      expression: |
        ${
          const numParams = inputs.simulations_params.length;
          const result = [];
          for (let p = 0; p < numParams; p++) {
            result.push(Math.floor(Math.random() * 1000000));
          }
          return { random_numbers: result };
        }
    in:
      simulations_params: list_files/files
    out: [random_numbers]
  import_par:
    run: cwl/import_par.cwl
    scatter: import_json
    in:
      import_json: list_files/files
    out: [output_rdata]
  run_simulation_wrapper:
    run: cwl/run_simulation_wrapper.cwl
    scatter: [simulation_params, seed]
    scatterMethod: dotproduct
    in:
      simulation_number: simulation_number
      simulation_params: import_par/output_rdata
      seed: generate_randoms/random_numbers
    out: [info_file_output, tar_file_output]