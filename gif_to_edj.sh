# Set the animation speed, smaller numbers are faster
SPEED=15

for GIF in *.gif
do
    # get the name of the file, minus the .gif extension
    name=${GIF%.gif}
    rm -rf $name
    mkdir $name
    cp $GIF $name
    cd $name

    echo "Processing $GIF"
    convert -coalesce $GIF $name.png

    cat >> $name.edc <<EOF
#define smoothValue 0

// Images definition
images 
{
EOF

    FRAMES=$(ls *.png | sort -n -t - -k 3)

    for PNG in $FRAMES
    do
        echo >> $name.edc "    image: \"$PNG\" COMP;"
    done

    cat >> $name.edc <<EOF
}

collections
{
    group
    {
        // the main background
        name: "e/desktop/background";
        parts
        {

            /* The images loop */
            part
            {
                name: "loop";
                mouse_events: 1;
                description
                {
                    state: "default" 0.0;
                    color: 255 255 255 255;
                    align: 0.5 0.5;
                    image {
EOF

    COUNTER=0
    for PNG in $FRAMES
    do
        if [ $COUNTER -eq 0 ]
        then
            echo >> $name.edc "                        normal: \"$PNG\";"
        else
            echo >> $name.edc "                        tween:  \"$PNG\";"
        fi
        ((COUNTER++))
    done

    cat >> $name.edc <<EOF
                    }
                }
            }

        programs
        {
            program
            {
                name:   "init";
                signal: "load";
                source: "";
                after:  "loop_animate";
            }

            program
            {
                name:          "loop_animate";
                source:        "loop";
                action:        STATE_SET "default" 0.0;
                transition:    LINEAR 
EOF
    echo >> $name.edc $SPEED";"
    cat >> $name.edc <<EOF
                target:        "loop";
                after:         "loop_animate";
            }

        }
    }
}
EOF

    edje_cc $name.edc
    cp $name.edj ..
    cp $name.edj ~/.e/e/backgrounds
    cd ..
done
