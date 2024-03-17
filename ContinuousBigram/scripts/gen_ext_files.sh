#!/bin/ksh

OPTIONS_FILE=$1
. ${OPTIONS_FILE}


echo
echo "*****************************************************"
echo converting data files to .ext files
echo "*****************************************************"
# rm -rf $EXT_DIR/*
if [[ ! -f "${EXT_DIR}/done" ]]; then
    for n in $(cat ${DATAFILES_LIST});
    do
      fname="data/${n##*/}"
      if [[ ! -d `dirname ${EXT_DIR}/$fname` ]]; then
     	echo "Making Directory: `dirname ${EXT_DIR}/$fname`"
     	mkdir -p `dirname ${EXT_DIR}/$fname`
      fi
          ${PREPARE_DATA} $n ${VECTOR_LENGTH} ${EXT_DIR}/$fname.ext $SAMPLE_PERIOD
    #      echo converted $fname to `ls ${EXT_DIR} | tail -n 1`
    
    done
    echo "1" > ${EXT_DIR}/done
fi

