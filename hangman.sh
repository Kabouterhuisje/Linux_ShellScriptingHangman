#!/usr/bin/env bash

#Ongeldige invoer afvangen, gebruiker is gefrusreerd of wil stoppen. 
#Wij gebruiken SIGINT in plaats van EXIT, omdat we in de gameloop exit 0 gebruiken.
#Deze zal met EXIT dus ook worden afgevangen, en een gebruiken kan dan nooit winnen. 
trap handler_int SIGINT
#Volledige directory naam van het script, maakt niet uit waar hij wordt uitgevoerd
readonly script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
readonly max_faults=10

word=""

#Juiste woord tonen wanneer gebruiker stopt/ongeldige invoer geeft
handler_int()
{
	clear_screen
	printf "${EXIT_text}" "${word}"
	exit 3
}

instruction()
{
	printf "${INVALIDARG_text}";
}

#scherm legen
clear_screen()
{
	printf "\ec"
}

#random woord genereren
get_random_word()
{
	local dictionary=$1
	local wordcount
	local index
	local word
	
	#woorden tellen in dictionary, awk pakt het eerste field
	wordcount=$(wc -l "${dictionary}" | awk '{print $1}')
	#index zetten (random)
	index=$(shuf -i "1-${wordcount}" -n1)
	#random woord zetten door index mee te geven aan stream editor
	word=$(sed "${index}q;d" "${dictionary}")

	#woord printen
	echo "${word}"
}

#tekenen van de galg
draw_hangman()
{
	if [ "$1" -eq 1 ]; then
		echo "          __________"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "      _____________|_____"
		echo "                           " 
	fi
	if [ "$1" -eq 2 ]; then
		echo "          __________"
		echo "         |         |"
		echo "         |         |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "      _____________|_____"
		echo "                           " 
	fi
	if [ "$1" -eq 3 ]; then
		echo "          __________"
		echo "         |         |"
		echo "         |         |"
		echo "       _/_\_       |"
		echo "        |_|        |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "      _____________|_____"
		echo "                           " 
	fi
	if [ "$1" -eq 4 ]; then
		echo "          __________"
		echo "         |         |"
		echo "         |         |"
		echo "       _/_\_       |"
		echo "        |_|        |"
		echo "         |         |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "      _____________|_____"
		echo "                           " 
	fi
	if [ "$1" -eq 5 ]; then
		echo "          __________"
		echo "         |         |"
		echo "         |         |"
		echo "       _/_\_       |"
		echo "        |_|        |"
		echo "         |         |"
		echo "         |         |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "      _____________|_____"
		echo "                           " 
	fi
	if [ "$1" -eq 6 ]; then
		echo "          __________"
		echo "         |         |"
		echo "         |         |"
		echo "       _/_\_       |"
		echo "        |_|        |"
		echo "         |         |"
		echo "         |         |"
		echo "         |         |"
		echo "         |         |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "      _____________|_____"
		echo "                           " 
	fi
	if [ "$1" -eq 7 ]; then
		echo "          __________"
		echo "         |         |"
		echo "         |         |"
		echo "       _/_\_       |"
		echo "        |_|        |"
		echo "         |         |"
		echo "      ---|         |"
		echo "         |         |"
		echo "         |         |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "      _____________|_____"
		echo "                           " 
	fi
	if [ "$1" -eq 8 ]; then
		echo "          __________"
		echo "         |         |"
		echo "         |         |"
		echo "       _/_\_       |"
		echo "        |_|        |"
		echo "         |         |"
		echo "      ---|---      |"
		echo "         |         |"
		echo "         |         |"
		echo "                   |"
		echo "                   |"
		echo "                   |"
		echo "      _____________|_____"
		echo "                           " 
	fi
	if [ "$1" -eq 9 ]; then
		echo "          __________"
		echo "         |         |"
		echo "         |         |"
		echo "       _/_\_       |"
		echo "        |_|        |"
		echo "         |         |"
		echo "      ---|---      |"
		echo "         |         |"
		echo "         |         |"
		echo "        /          |"
		echo "       /           |"
		echo "                   |"
		echo "      _____________|_____"
		echo "                           " 
	fi
	if [ "$1" -eq 10 ]; then
		echo "          __________"
		echo "         |         |"
		echo "         |         |"
		echo "       _/_\_       |"
		echo "        |_|        |"
		echo "         |         |"
		echo "      ---|---      |"
		echo "         |         |"
		echo "         |         |"
		echo "        / \        |"
		echo "       /   \       |"
		echo "                   |"
		echo "      _____________|_____"
		echo "                           " 
	fi
}

#status printen
print_status()
{
	local faults=$1
	local letters=$2
	local word=$3

	clear_screen

	if [ $((max_faults - faults)) -eq 1 ]; then
		printf "${LASTGUESS_text}"
		draw_hangman $faults
	else
		printf "${GUESSES_text}" "$((max_faults - faults))"
		draw_hangman $faults
	fi

	printf "${LETTERS_text}" "${letters}"
	printf "${WORD_text}" "$(make_guessable_word "${word}" "${letters}")"
	echo
	printf "${INPUT_text}"
}

#Het te raden woord, weergegeven door puntjes
make_guessable_word()
{
	local word=$1
	local untried=$2

	for ((i = 0; i < ${#untried}; i++)); do
		word=${word//${untried:${i}:1}/.}
	done

	echo "${word}"
}

#user input lezen
read_input()
{
	read -r -n1 input
	echo "${input}"
}

#main functie met daarin een single game
main()
{
	local dictionary
	local guesses
	local untried
	local input
	local guessable
	local language="en"
	local faults

	#opties ontleden, mogelijkheden
	while getopts "d:l:w:" opt; do
		case ${opt} in
			d)
				if ! [ -f "${OPTARG}" ]; then
					echo "No file found at ${OPTARG}"
					exit 2
				fi

				dictionary=${OPTARG}
			;;
			l)
				language=${OPTARG}
			;;
			w)
				word=${OPTARG}
			;;
			:)
				echo "Option ${OPTARG} requires an argument."
			;;
			\?)
				#invalid argument, laat instruction tekst zien
				instruction
				exit 1
			;;
		esac
	done

	#juiste language file laden, staat standaard op engels
	langfile=${script_dir}/lang/${language}.sh
	if ! [ -f "${langfile}" ]; then
		echo "Specified language file could not be found!"
		exit 4
	fi

	#game instellingen worden klaar gezet
	source "${langfile}"

	if [ -z "${dictionary}" ]; then
		dictionary=/usr/share/dict/words
	fi

	if [ -z "${word}" ]; then
		word=$(get_random_word ${dictionary})
	fi

	guesses=0
	faults=0
	untried="abcdefghijklmnopqrstuvwxyz"

	#game gaat door tot de gebruiker heeft gewonnen of verloren
	while [ ${faults} -lt $((max_faults)) ]; do
		guessable=$(make_guessable_word "${word}" "${untried}")
		print_status "${faults}" "${untried}" "${guessable}"
		input=$(read_input)

		#checken of de letter al geraden is
		if [ "$(echo "${untried}" | grep -o "${input}")" == "" ]; then
			continue
		fi

		#lijst met nog niet geprobeerde letters updaten
		untried=${untried//${input}/ }

		#checken of de gebruiker een letter fout heeft geraden
		if [ "${guessable}" == "$(make_guessable_word "${word}" "${untried}")" ]; then
			faults=$((faults + 1))
		fi

		#checken of je gewonnen hebt
		if [ "${word}" == "$(make_guessable_word "${word}" "${untried}")" ]; then
			clear_screen
			printf "${WIN_text}" "${word}" "${faults}"

			# highscore opslaan in highscore file
			echo "${USER} ${faults}" >> "${script_dir}/highscore"

			exit 0
		fi

		#guesses updaten
		guesses=$((guesses + 1))
	done

	#gebruiker verliest
	clear_screen
	printf "${EXIT_text}" "${word}"
}

main "$@"

