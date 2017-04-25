cwlVersion: v1.0
class: CommandLineTool
baseCommand: /home/johan/localApps/data-integration/pan.sh
#kitchen can be used if you want to run a job. currently we want to run a transformation
inputs:
    pentaho_script_file:
        type: ["null", File]
        inputBinding:
            position: 1
            prefix: /file
    pentaho_logging_level:
        type: string
        inputBinding:
            position: 2
    pentaho_logfile_location:
        type: string
        inputBinding:
            position: 3
outputs:
    message_out:
        type: stdout
