#!/bin/bash

set -ex

config_file=${CONFIG:-config.yaml}
source_suffix=${SOURCE_SUFFIX:-.yaml}
target_suffix=${TARGET_SUFFIX:-.yaml}
if [[ "$source_suffix" == ".yaml" ]]; then
    source_suffix=$(yq ".source.mycnfsuffix" $config_file)
fi
if [[ "$target_suffix" == ".yaml" ]]; then
    target_suffix=$(yq ".target.mycnfsuffix" $config_file)
fi

function convert_number_to_certification() {
    case $1 in
        5) echo "major";;
        4) echo "major-solo";;
        3) echo "certified";;
        2) echo "solo";;
        1) echo "training";;
        0) echo "none";;
        *) echo "none";;
    esac
}

while IFS=$'\t' read id firstname lastname email initials rating_id canTrain visitor visitorfrom discord status max remember_token loa del gnd twr app ctr ots created_at updated_at; do
    echo "Converting $id $firstname $lastname"

    #lastname=$(echo $lastname | sed "s/\'//g") # For a dev environment, it's okay if O'Neill becomes ONeill... in prod, runner will fix this

    del=$(convert_number_to_certification $del)
    gnd=$(convert_number_to_certification $gnd)
    twr=$(convert_number_to_certification $twr)
    app=$(convert_number_to_certification $app)
    ctr=$(convert_number_to_certification $ctr)

    if [[ "$initials" == "NULL" ]]; then
        initials=""
    fi

    controllertype="none"
    if [[ "$visitor" == "1" ]]; then
        controllertype="visitor"
    elif [[ "$status" == "0" ]]; then
        controllertype="home"
    fi

    controllerstatus="active"
    if [[ "$controllertype" == "none" ]]; then
        controllerstatus="none"
    elif [[ "$loa" == "1" ]]; then
        controllerstatus="loa"
    fi

    mysql --defaults-group-suffix=$target_suffix -e "REPLACE INTO users (c_id, first_name, last_name, email, operating_initials, controller_type, rating_id, discord_id, status, del_certification, gnd_certification, lcl_certification, app_certification, ctr_certification, created_at, updated_at) VALUES ($id, '$firstname', \"$lastname\", '$email', '$initials', '$controllertype', $rating_id, '$discord', '$controllerstatus', '$del', '$gnd', '$twr', '$app', '$ctr', '$created_at', '$updated_at');"
done < <(mysql --defaults-group-suffix=$source_suffix -se "SELECT * FROM roster where id > 1371000;")