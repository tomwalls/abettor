#' Change bet persistence type
#' \link{https://api.developer.betfair.com/services/webapps/docs/display/1smk3cen4v3lu3yomq5qye0ni/updateOrders}
#' 
#' \code{updateOrders} changes the persistence type of a specific unmatched bet.
#' 
#' @seealso \code{\link{loginBF}}, which must be executed first. Do NOT use the 
#'   DELAY application key. The DELAY application key does not support price
#'   data.
#'   
#' @param marketId String. The market ID of the bets to be updated. While many
#'   bets can be updated in one call, they must be from the same market.
#'   
#' @param betID vector (strings). The bet IDs of the bets to be updated- bet IDs
#'   are displayed (called Ref) on the bet information on the right hand side of
#'   market page on the betfair desktop site.
#'   
#' @param PersistenceType vector (strings). The persistence state of updated
#'   bets. PersistanceType can take three values
#'   ("LAPSE","PERSIST","MARKET_ON_CLOSE", which correspond to Cancel, Keep and
#'   Take SP on the desktop website)
#'   
#' @param sslVerify Boolean. This argument defaults to TRUE and is optional. In 
#'   some cases, where users have a self signed SSL Certificate, for example 
#'   they may be behind a proxy server, Betfair will fail login with "SSL 
#'   certificate problem: self signed certificate in certificate chain". If this
#'   error occurs you may set sslVerify to FALSE. This does open a small 
#'   security risk of a man-in-the-middle intercepting your login credentials.
#'   
#' @return If the call is successful, then the function returns "SUCCESS".
#'   Otherwise, a string indicating the nature of the error is returned.
#'   
#' @section Notes on \code{priceData} options: There are three options for this 
#'   argument and one of them must be specified. All upper case letters must be 
#'   used. \describe{ \item{SP_AVAILABLE}{Amount available for the Betfair 
#'   Starting Price (BSP) auction.} \item{SP_TRADED}{Amount traded in the 
#'   Betfair Starting Price (BSP) auction. Zero returns if the event has not yet
#'   started.} \item{EX_BEST_OFFERS}{Only the best prices available for each 
#'   runner.} \item{EX_ALL_OFFERS}{EX_ALL_OFFERS trumps EX_BEST_OFFERS if both 
#'   settings are present} \item{EX_TRADED}{Amount traded in this market on the 
#'   Betfair exchange.}}
#'   
#' @section Note on \code{updateOrders}: Unlike some other functions that
#'   utilised data frames, this function converts the input to a JSON-compatible
#'   format. The JSON output is then converted back to a data frame.
#'   
#' @examples
#' \dontrun{
#' # Update two bets on the same market so that they will persist in play. The following
#' variables are for illustrative purposes and don't represent actual Betfair IDs:
#' 
#' updateOrders("1.10271480",c("61385423029","61385459133"),c("PERSIST","PERSIST") )
#' 
#' Note that if you run this function again, it will return an error (BET_ACTION_ERROR (NO_ACTION_REQUIRED)) as the bets are already set to "PERSIST".
#' 
#' Now, if you run the function for a third time, but with one "LAPSE" and one "PERSIST", it will again return a different error (PROCESSED_WITH_ERRORS).
#' This is because all bets need to be successful to return "SUCCESS". Please note, however, that the viable
#' bet IDs will have been succesfully updated i.e. it's not an all or nothing process but rather each update is treated individually (unlike \code{replaceOrders}, for example).
#' 
#' Another possible error occurs if you input incorrect data. In these scenarios, no updates will have been processed and "No Data Returned" will be the function output.
#' }
#' 

updateOrders <- function(marketID,betID,PersistenceType,sslVerify = TRUE){
  
  options(stringsAsFactors=FALSE)
if(length(betID)!=length(PersistenceType))
  return("Bet ID and Persistence Type vector need to have the same length")
  updateOrderOps <- paste0('[{"jsonrpc": "2.0","method": "SportsAPING/v1.0/updateOrders","params":{"marketId": "',marketID,'","instructions": [',
         paste0(sapply(as.data.frame(t(data.frame(betID,PersistenceType))),function(x)paste0('{"betId":"',x[1],'","newPersistenceType":"',x[2],'"}')),collapse=","),']},"id": "1"}]')
  updateOrderOps <- as.list(jsonlite::fromJSON(RCurl::postForm("https://api.betfair.com/exchange/betting/json-rpc/v1", .opts=list(postfields=updateOrderOps, httpheader=headersPostLogin, ssl.verifypeer = TRUE))))
  output<-as.data.frame(updateOrderOps$result)
  if(length(output)==0)
    return("No Data Returned")
  if(output$status=="SUCCESS")
    return(output$status)
  return(paste0(output$status,": ",output$errorCode," (",as.data.frame(output$instructionReports)$errorCode,")"))
}