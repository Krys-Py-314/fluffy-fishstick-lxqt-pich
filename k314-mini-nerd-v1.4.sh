#!/usr/bin/env bash

################################################################################
#                                                                              #
#  nerd-installer.sh - Install the entire Nerd Fonts collection effortlessly   #
#  Version: 3.5.0                                                              #
#                                                                              #
#  This program is free software: you can redistribute it and/or modify        #
#  it under the terms of the GNU General Public License as published by        #
#  the Free Software Foundation, either version 3 of the License, or           #
#  (at your option) any later version.                                         #
#                                                                              #
#  This program is distributed in the hope that it will be useful,             #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of              #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               #
#  GNU General Public License for more details.                                #
#                                                                              #
#  You should have received a copy of the GNU General Public License           #
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.      #
#                                                                              #
################################################################################

for cmd in uname unzip wget fc-cache; do
	if ! command -v "$cmd" &>/dev/null; then
		printf "Error: This script requires '%s', but it's not installed.\n" "$cmd" >&2
		printf "Please install it and try again.\n" >&2
		exit 1
	fi
done

nerd_fonts_release_version='3.5.0'
os="$(uname)"

if [[ $os == "Linux" || $os == "FreeBSD" ]]; then
	fonts_dir="${HOME}/.local/share/fonts"
elif [[ $os == "Darwin" ]]; then
	fonts_dir="${HOME}/Library/Fonts"
else
	printf "Unsupported operating system: %s\n" "$os"
	exit 1
fi

declare -a fonts=(
	0xProto
	3270
	AdwaitaMono
	Agave
#	AnnotationMono
#	AnonymousPro
#	Arimo
	AtkinsonHyperlegibleMono
	AurulentSansMono
#	BigBlueTerminal
#	BitstreamVeraSansMono
	CascadiaCode
	CascadiaMono
#	CodeNewRoman
#	ComicShannsMono
	CommitMono
#	Cousine
#	D2Coding
#	DaddyTimeMono
	DejaVuSansMono
#	DepartureMono
#	DroidSansMono
#	EnvyCodeR
	FantasqueSansMono
	FiraCode
	FiraMono
	GeistMono
#	Go-Mono
#	Gohu
#	GoogleSansCode
	Hack
	Hasklig
#	HeavyData
	Hermit
#	IBMPlexMono
	Inconsolata
	InconsolataGo
	InconsolataLGC
	IntelOneMono
	Iosevka
	IosevkaTerm
	IosevkaTermSlab
	JetBrainsMono
#	Lekton
	LiberationMono
	Lilex
#	MPlus
#	MartianMono
#	Meslo
	Monaspace
	Monofur
#	Monoid
#	Mononoki
#	NerdFontsSymbolsOnly
	# Noto
#	OpenDyslexic
#	Overpass
#	ProFont
#	ProggyClean
#	Recursive
	RobotoMono
	ShareTechMono
	SourceCodePro
#	SpaceMono
#	Terminus
#	Tinos
	Ubuntu
	UbuntuMono
	UbuntuSans
#	VictorMono
#	ZedMono
#	iA-Writer
)

if [[ ! -d "$fonts_dir" ]]; then
	mkdir -p "$fonts_dir"
fi

printf "\n    -------------------------"
printf "\n    Welcome to Nerd Installer"
printf "\n    -------------------------\n"
printf "\n    Target instal dir : %s" "$fonts_dir"
printf "\n    NerdFonts version : %s" "$nerd_fonts_release_version"
printf "\n    Fonts to install  : %s" ${#fonts[@]}
printf "\n"
printf "\n    If you wish to change this, abort and comment"
printf "\n    out any unwanted fonts in this script."
printf "\n\n    Press ENTER to install, C-c to abort.\n\n"
read -r

for font in "${fonts[@]}"; do
	((count++))
	zip_file="${font}.zip"
	download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${nerd_fonts_release_version}/${zip_file}"
	printf ">>> Downloading and installing %s: %s...\n" $count "${font}"
	wget -q "$download_url"
	unzip -o -qq "$zip_file" -d "$fonts_dir"
	rm "$zip_file"
done

find "$fonts_dir" -name '*Windows Compatible*' -delete

printf ">>> Updating user cache...\n"
fc-cache -fv
printf ">>> Font cache for user %s updated.\n\n" "$USER"

