/*! @file trdr.cpp 
 @author weaves
 @date November 2008
 @brief Documentation for the trader system
*/

/*! 

\page trader Trading for Services

\section tr0 Introduction

The trader service provides a way of organizing Q services. 

A dedicated server runs on the host and port specified by the environment variable
usually defined in q.rc.

The service starts with no invocation: Qp -p 14901 will start it.

It maintains a table of offers and of the types and properties each has.

Offers are made by exporting to the trader. An export() is performed
when a q/server starts. It is best to use modify() to change the offer
when the service has initialised itself. Such a service is in a client
to the trader in the exporter role.

After a service has exported itself, the trader can be queried for a
service having a particular type and properties. A client to the
trader in this role is an importer.

Exporters may withdraw() their offers. They are withdrawn when they 
disconnect from trader.

Importers are not informed when an exporter has withdrawn their offer.

All exporters support a basic interface that allows them to contacted
to discover other types they may support and other properties of their
implementation.

\section trs Trader Service

 The trader service is implemented in trdr.q. This is loaded by trdrc.q
 when the port is 15001 (or the host and port given by QTRDR, which is usually
 set in q.rc)

\section trx Trader Export

 A q/kdb server will export a unique offer for itself on startup if it has
 QTRDR variable set and the trader is running.

 Once the service is running, it should modify() its offer.

\section tri Trader Import

 Once a trader is runing, it can be interrograted for services it has offers
 for.

*/


