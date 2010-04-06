// @file bench.q
//
// This file is a benchmark that tries to measure latency by making repeated calls
// to a server process to calculate "2+2". 
//
// This file also is usable for the server process.
//
// @author niall@kx.com
// @date 2007-04-10
//

/ I assume here that repeatedly executing 2+2 on the server is a reasonable
/ benchmark to see the latency of the calls.

// The "Benchmark" code to run.
benchmark : {[]
   2+2;
 }

// The number of iterations to execute by default.
iterations : 10000

// The default port to use in the server process.
port : 5000

// A function to print to a value to stdout.
//
// @param val The value to print
echo : {[val]
  $[10h=type val; -1 val; -1 (string val)]   
 }

// A function to convert a hostname and port number into a destination
// that we can connect to using hopen.
//
// @param host The hostname of the remote machine
// @param port The remote port to connect to
// @return A symbolic descriptor for the remote host:port
asDestination : {[host;port]
  hsym `$(":", host, ":", string port)
 }

// A function to convert a filename into a file descriptor we can open 
// using hopen.
//
// @param filename The filename to make into a descriptor
// @return The symbolic file descriptor
asFile : {[filename]
  hsym `$(":", filename)
 }

// The command line arguments
argv : .z.x

// The number of command line arguments
argc : count .z.x

// The command line arguments as a dictionary. "-flag arg" is processed so
// `flag is a key and arg is the associated value.
argvAsDictionary : .Q.opt .z.x

// A function to check whether we were passed a certain command line argument
// 
// @param arg The symbolic form of a command line argument we are checking
// @return true if we were passed this argument, otherwise false
haveArgument : {[arg]
  arg in key argvAsDictionary
 }

/ Check that we have at least one of remote and server flags. If not
/ print usage and exit.
if [(not haveArgument[`remote]) and (not haveArgument[`server]);
  echo "Usage: q cisco.q (-remote hostname | -server) [-port number] [-iterations number] [-save run.log] [-exit]";
  exit 1;
 ] 

/ Override the default port if we are passed one.
if [haveArgument[`port];
  port : value first argvAsDictionary[`port]
 ]

/ Start listening on the port if we're the server
if [haveArgument[`server];
  system ("p ", string port)
 ]

/ Override the number of iterations to execute if we are passed one.
if [haveArgument[`iterations];
  iterations : value first argvAsDictionary[`iterations];
 ]

// Performs an RPC call to execute one call to the benchmark function.
//
// @param handle an open handle to the remote server
// @return returns whatever the benchmark server returns
rpcOnce : {[handle]
  handle["benchmark[]"]
 }

// Try to connect to the remote server on the given port. If we fail, then complain
// and exit.
//
// @param server The server to connect to
// @param port The port on which to connect
// @return The open connection handle
createHandleOrDie : {[server; port]
  host : asDestination[server;port];
  @[hopen; host; {echo "Could not connect to server; exiting."; exit -1;}] 
 }

// A function to open a connection to the server and execute 'iterations' number
// of RPC calls to the server. Save the timing data in the log file if requested.
executeRemoteCalls : {[]
  server :: first argvAsDictionary[`remote];
  handle :: createHandleOrDie[server; port];
  time : system ("t do[iterations; rpcOnce[handle]]");
  averageTime : time % iterations;
  if [haveArgument[`save];
    filename : first argvAsDictionary[`save];
    file : hopen (asFile filename);
    file ((string .z.z), ",", (string iterations), ",", (string averageTime), "\n");
   ]
 }

/ If we're the client, make the RPC calls.
if [haveArgument[`remote];
  executeRemoteCalls[]
 ]

/ Exit if requested.
if [haveArgument[`exit];
  exit 1
 ]
