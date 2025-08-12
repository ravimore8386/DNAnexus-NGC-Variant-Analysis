#!/bin/bash
# ngc_snv variant filtering grch38

set -exo pipefail

main() {

    echo "Value of input_annot_tab_file: '$input_annot_tab_file'"
    echo "Value of input_family_file: '$input_family_file'"
    echo "Value of input_manifest_file: '$input_manifest_file'"
    
    time dx-download-all-inputs --parallel
    
    mkdir -p out/outfiles
    
    #Permissions to write to /home/dnanexus
    chmod a+rwx /home/dnanexus

    # unpack sv pipeline bundle
    tar -xzf /home/dnanexus/ngc_variant_filtering_grch38.tar.gz

    find ~/in/input_annot_tab_file -type f -name "*" -print0 | xargs -0 -I {} mv {} ~/ngc_variant_filtering_grch38/input/

    find ~/in/input_family_file -type f -name "*" -print0 | xargs -0 -I {} mv {} ~/ngc_variant_filtering_grch38/config/

    find ~/in/input_manifest_file -type f -name "*" -print0 | xargs -0 -I {} mv {} ~/ngc_variant_filtering_grch38/config/

    echo "files are copied"

    #install conda, create, run env
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh

    bash ~/miniconda.sh -b -p $HOME/miniconda

    eval "$(/home/dnanexus/miniconda/bin/conda shell.bash hook)"

    conda init

    conda deactivate

    conda config --set auto_activate_base false

    conda

    conda env create -f /home/dnanexus/ngc_snv_env.yml

    conda activate ngc_snv
    
    #Run snv variant filtering script
    sh /home/dnanexus/ngc_variant_filtering_grch38/1_create_r_cmd.sh

    #copy results files to home upload dir
    cp -r /home/dnanexus/ngc_variant_filtering_grch38/output/* /home/dnanexus/out/outfiles/
    
    conda deactivate
    
    # upload output 
    dx-upload-all-outputs --parallel
}
