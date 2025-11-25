#!/bin/bash

set -euo pipefail
mkdir -p /home/comvis/Bee_monitoring/record \
         /home/comvis/Bee_monitoring/yolov5/result
# Define timestamp
timestamp=$(date +'%Y-%m-%d_%H-%M-%S')
echo "==== Starting record_proc_send.sh ===="
. /home/comvis/Bee_monitoring/bee/bin/activate
# Execute record.py script with specified name
python /home/comvis/Bee_monitoring/cam/record.py --name "pi02_${timestamp}.mp4"
# Change directory to yolov5
cd /home/comvis/Bee_monitoring/yolov5

# Execute detect2_csv.py script with specified parameters
python detect2_csv.py --weight /home/comvis/Bee_monitoring/yolov5/yolov5n-bee.pt --hide-labels --hide-conf --conf-thres 0.75 --source /home/comvis/Bee_monitoring/record/"pi02_${timestamp}.mp4"

mkdir -p /home/comvis/Bee_monitoring/record/h264
ffmpeg -i /home/comvis/Bee_monitoring/record/"pi02_${timestamp}.mp4" \
       -c:v libx264 -pix_fmt yuv420p -vtag avc1 -movflags +faststart \
       /home/comvis/Bee_monitoring/record/h264/"pi02_${timestamp}.mp4"

# Execute send.py script with specified parameters
python send.py --input /home/comvis/Bee_monitoring/record/h264/"pi02_${timestamp}.mp4" \
                --output /home/comvis/Bee_monitoring/yolov5/result/"pi02_${timestamp}"/"pi02_${timestamp}.mp4" \
                --info /home/comvis/Bee_monitoring/yolov5/result/"pi02_${timestamp}"/additional_info.csv
deactivate
echo "==== Finished ===="