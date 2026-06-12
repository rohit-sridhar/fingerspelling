#!/usr/bin/env bash
set -euo pipefail

OPTIONS_FILE=$1
. ${OPTIONS_FILE}

echo
echo "*****************************************************"
echo converting data files to .ext files
echo "*****************************************************"
## Above is done in prepare_files now
# rm -rf $EXT_DIR/*
# if [[ ! -f "${EXT_DIR}/done" ]]; then

for n in $(cat ${DATAFILES_LIST}); do
    fname="data/${n##*/}.ext"
    if [[ ! -d `dirname ${EXT_DIR}/$fname` ]]; then
      echo "Making Directory: `dirname ${EXT_DIR}/$fname`"
      mkdir -p `dirname ${EXT_DIR}/$fname`
    fi
    
    ext_all_file="${EXT_DIR%$(echo "${EXT_DIR}" | cut -d/ -f10-)}all/${fname}"
    if [[ ! -f ${ext_all_file} ]]; then
        # echo "${ext_all_file} doesn't exist"
        ${PREPARE_DATA} ${n} ${VECTOR_LENGTH} ${EXT_DIR}/${fname} ${SAMPLE_PERIOD} 2>&1
    else
        # echo "${ext_all_file} does exist"
        cp -l ${ext_all_file} ${EXT_DIR}/${fname}
    fi
#      echo converted $fname to `ls ${EXT_DIR} | tail -n 1`
done
echo "1" > ${EXT_DIR}/done

