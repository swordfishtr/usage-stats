#!/usr/bin/env bash
shopt -s extglob

# Generates all-time usage stats for the specified format.
# This is the script Generations formats use.

echo "$(date)"

logs="/home/hog/pokemon-showdown/logs/"
target="${1%/}"

[[ "${target}" = +([[:alnum:]]) ]] || {
	echo "Invalid format specified"
	exit 1
}

echo "Collecting usage stats for ${target} from ${logs}"

(( proceed=0 ))

[[ -d "Raw" ]] && rm -r "Raw"
[[ -f "Stats/${target}-0.txt" ]] && rm "Stats/${target}-0.txt"
[[ -f "Stats/chaos/${target}-0.txt" ]] && rm "Stats/chaos/${target}-0.txt"
[[ -f "Stats/leads/${target}-0.txt" ]] && rm "Stats/leads/${target}-0.txt"
[[ -f "Stats/metagame/${target}-0.txt" ]] && rm "Stats/metagame/${target}-0.txt"
[[ -f "Stats/moveset/${target}-0.txt" ]] && rm "Stats/moveset/${target}-0.txt"

echo
echo "Running batchLogReader.py"

for month in "${logs}"+([[:digit:]-])/
do
	[[ -d "${month}" ]] || break
	echo "${month}"
	for day in "${month}${target}/"*/
	do
		[[ -d "${day}" ]] || break
		echo "${day}"
		python3 batchLogReader.py "${day}" "${target}" && (( proceed=1 ))
	done
done

(( proceed )) || {
	echo
	echo "No logs found"
	exit 1
}
(( proceed=0 ))

echo
echo "Running StatCounter.py"

python3 StatCounter.py "${target}" 0 && (( proceed=1 ))

(( proceed )) || {
	echo
	echo "Failed"
	exit 1
}
(( proceed=0 ))

echo
echo "Running batchMovesetCounter.py"

mkdir "Stats/moveset"
python3 batchMovesetCounter.py "${target}" 0 > "Stats/moveset/${target}-0.txt" && (( proceed=1 ))

(( proceed )) || {
	echo
	echo "Failed"
	exit 1
}

echo
echo "Finished"
