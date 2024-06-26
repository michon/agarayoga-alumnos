{
    "protocol": "ftp",
    "host": "ftp.agarayoga.eu", // string - The hostname or IP address of the FTP server. Default: 'localhost'
    "port": 21, // integer - The port of the FTP server. Default: 21
    "user": "web@agarayoga.eu", // string - Username for authentication. Default: 'anonymous'
    "pass": " )D1xY(7VyT", // string - Password for authentication. Default: 'anonymous@'
    "promptForPass": false, // boolean - Set to true for enable password dialog. This will prevent from using cleartext password in this config. Default: false
    "remote": "/",
    "secure": false, // mixed - Set to true for both control and data connection encryption, 'control' for control connection encryption only, or 'implicit' for implicitly encrypted control connection (this mode is deprecated in modern times, but usually uses port 990) Default: false
    "secureOptions": null, // object - Additional options to be passed to tls.connect(). Default: (null) see https://nodejs.org/api/tls.html#tls_tls_connect_options_callback
    "connTimeout": 10000, // integer - How long (in milliseconds) to wait for the control connection to be established. Default: 10000
    "pasvTimeout": 10000, // integer - How long (in milliseconds) to wait for a PASV data connection to be established. Default: 10000
    "keepalive": 10000, // integer - How often (in milliseconds) to send a 'dummy' (NOOP) command to keep the connection alive. Default: 10000\. If set to 0, keepalive is disabled.
    "watch":[ // array - Paths to files, directories, or glob patterns that are watched and when edited outside of the atom editor are uploaded. Default : []
        "dist/stylesheets/main.css", // reference from the root of the project.
        "dist/stylesheets/",
        "dist/stylesheets/*.css"
    ],
    "watchTimeout":500 // integer - The duration ( in milliseconds ) from when the file was last changed for the upload to begin.
}
