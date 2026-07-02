#!/usr/bin/env bash
set -euo pipefail

OPTIONS_FILE=$1
. ${OPTIONS_FILE}

function gen_ext_files {
    data_files_list=$1
    for n in $(cat ${data_files_list}); do
        fname="data/${n##*/}.ext"
        if [[ ! -d `dirname ${EXT_DIR}/$fname` ]]; then
          echo "Making Directory: `dirname ${EXT_DIR}/$fname`"
          mkdir -p `dirname ${EXT_DIR}/$fname`
        fi
        
        ext_all_file="${EXT_DIR%$(echo "${EXT_DIR}" | cut -d/ -f10-)}all/${fname}"
        if [[ ! -f ${ext_all_file} ]]; then
            echo "${PREPARE_DATA} ${n} ${VECTOR_LENGTH} ${EXT_DIR}/${fname} ${SAMPLE_PERIOD} 2>&1"
            ${PREPARE_DATA} ${n} ${VECTOR_LENGTH} ${EXT_DIR}/${fname} ${SAMPLE_PERIOD} 2>&1
        else
            cp -l ${ext_all_file} ${EXT_DIR}/${fname}
        fi
    #      echo converted $fname to `ls ${EXT_DIR} | tail -n 1`
    done
}

echo
echo "*****************************************************"
echo converting data files to .ext files
echo "*****************************************************"
## Above is done in prepare_files now
# rm -rf $EXT_DIR/*
# if [[ ! -f "${EXT_DIR}/done" ]]; then
if [[ ${MULTI_PROCESS} = "yes" ]]; then
    num_lines=`cat ${DATAFILES_LIST} | wc -l` #   compute the num lines per file
    lines_per_file=$((${num_lines} / ${THREADS}))
    if [[ ${lines_per_file} -lt 1 ]]; then
        lines_per_file=1
    fi
    split -l ${lines_per_file} ${DATAFILES_LIST} "${DATAFILES_LIST}."    # splits train files

    pid=()
    for data_files_list in ${DATAFILES_LIST}.*; do
        gen_ext_files ${data_files_list} &
        pid+=("$!")
    done
    wait "${pid[@]}"
else
    gen_ext_files ${DATAFILES_LIST}
fi

echo "1" > ${EXT_DIR}/done

