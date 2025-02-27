#!/bin/sh
#SBATCH --account=jhuguet-ctge
#SBATCH --qos=jhuguet-ctge
#SBATCH --partition=gpu      # hwgui for quadro; gpu for a100 or geforce
#SBATCH --gpus=a100:1
#SBATCH --job-name=BDM_ZCY_100                # Job name
#SBATCH --mail-type=END,FAIL                  # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=z.bao@ufl.edu             # Where to send mail
#SBATCH --nodes=1                             # Use one node
#SBATCH --ntasks=1                            # Run a single task
#SBATCH --cpus-per-task=4                     # Use 4 cores for these series
#SBATCH --mem=29gb                            # Use 29gb as the starting point
#SBATCH --time=4-00:00:00                     # Time limit hrs:min:sec, GPU max 14-00:00:00
#SBATCH --output=log/alphafold3_res_BDM_ZCY_100_%j.out       # Standard output and error log

date;hostname;pwd

ml singularity
mkdir -p log

for stem in $(ls BDM_ZCY_100/20250226_af3_jsons/ | cut -d "_" -f2- | cut -d "." -f1 | head -2);  # get the first two stem names to name res_folders
do

echo $stem
mkdir -p AF3_out/$stem # one folder store the results form one json file.

for json in $(ls $(pwd)/BDM_ZCY_100/20250226_af3_jsons/*$stem*);
do

echo $json
afin=$(pwd)/BDM_ZCY_100/20250226_af3_jsons/
afout=$(pwd)/AF3_out/$stem
param_dir=/blue/jhuguet/z.bao/AF3_model_parameters/af3.bin
out_dir=$(pwd)/AF3_out/$stem

singularity exec \
     --nv \
     --bind $afin:/root/af_input \
     --bind $afout:/root/af_output \
     --bind $param_dir:/root/models \
     --bind /data/reference/alphafold/3.0.0:/root/public_databases \
     /apps/alphafold/3.0.0/alphafold3.sif \
     python /app/alphafold/run_alphafold.py \
     --db_dir=/data/reference/alphafold/3.0.0 \
     --json_path=$json \
     --model_dir=$param_dir \
     --output_dir=$out_dir

done

done

