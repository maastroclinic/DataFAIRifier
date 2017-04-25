cwlVersion: v1.0
class: CommandLineTool
baseCommand: /home/johan/localApps/d2rq-0.8.3-dev/dump-rdf
arguments: [-o, d2r_output.ttl]
inputs:
    d2r_base_uri:
        type: string
        inputBinding:
            position: 2
            prefix: -b
    d2r_mapping_file:
        type: File
        inputBinding:
            position: 3
    verbose:
        type: boolean?
        inputBinding:
            prefix: --verbose
            position: 1
outputs:
    message_out:
        type: stdout
    d2r_out:
        type: File
        outputBinding:
            glob: d2r_output.ttl
