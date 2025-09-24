#!/bin/bash
#SBATCH --partition=noexcl
#SBATCH -N 1 
#SBATCH -n 1
#SBATCH --mem-per-cpu=4GB
#SBATCH --reservation=cancer_sim
#SBATCH --output=job_%j.out
#SBATCH --error=job_%j.err  
srun /opt/adw/bin/adw run -i qbioturin/cancer_simulator:0.0.6 -c "/bin/bash -c 'time {{streamflow_command}}'"