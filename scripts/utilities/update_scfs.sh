while getopts i:o: flag
do
    case "${flag}" in
        i) scf_in=${OPTARG};;
        o) out_dir=${OPTARG};;
    esac
done

if [ -d "${scf_in}" ] ; then 
    for file in ${scf_in}/* ; do
        xbase=${file##*/}
        
        scf_update $file ${out_dir}/${xbase} || echo "failed to update ${xbase}!"
        
    done

elif [ -f "${scf_in}" ] ; then
    xbase=${scf_in##*/}
    
    scf_update $file ${out_dir}/${xbase} || echo "failed to update ${xbase}!"
    
else echo "${scf_in} is not a valid input, please specify a directory containing scfs, or a single scf file";
     exit 1
fi

