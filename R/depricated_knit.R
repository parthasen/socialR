
########## DEPRICATED METHODS ############# 

#' Define the wordpress uploader method.  
#' @param x the image to be uploaded 
#' @details Make sure url and user/password are defined in options for 
#' this to work, i.e: 
#' options(WordPressLogin = c(userid = "password"), 
#'   WordPressURL = "http://www.yourdomain.com/xmlrpc.php")
#' @import RWordPress
#' @seealso uploadFile
#' @return the url, if uploaded.  otherwise, just the name of the file
.wordpress.url = function(x) {
  require(RWordPress)
  file = paste(x, collapse = '.')
  if (opts_knit$get('upload')) {
    uploadFile(file)$url
  } else file
}


#' Define the flickr uploader method using Rflickr
#' @param x the name of the image file to upload
#' @param id_only return the flickr id code? if false returns the static url
#' @param ... additional arguments to flickr.upload (public, description, tags)
#' @return the url, if uploaded.  otherwise, just the name of the file. 
#'  Optionally will return just the flickr id if id_only is TRUE
#' @details you'll need to define your secure details in options. 
#' Obtain an api_key and secret key for your account by registering
#' with the flickr API. Then use Rflickr to establish an authentication token
#' for this application.  Enter each of these using "options()"
#' @import Rflickr
#' @seealso flickr.upload 
.flickr.url = function(x, id_only = FALSE, ...){
  require(Rflickr)
  auth=getOption("flickr_tok") 
  api_key=getOption("flickr_api_key") 
  secret=getOption("flickr_secret")
  id <- flickr.upload(secret=secret, auth_token=auth,
                      api_key=api_key, image=file, ...)
  sizes_url <- flickr.photos.getSizes(secret=secret, auth_token=auth,
                                      api_key=api_key, photo_id=id)
   if(id_only) 
      out <- id
    else 
      out <- sizes_url[[5]][[4]]
    out
}



#' Create a hook that inserts my wordpress shortcode
hook_plot_flickr_shortcode = function(x, options) {
    sprintf('[flickr]%s[/flickr]', .flickr.url(x, id_only=TRUE))
}




#' define a wrapper to make a generic url image method html compatible
#' @param custom_url a function that uploads an image and returns a url
#' @param ... additional options for that function
#' @return a knitr hook for html 
#' @details shouldn't be necessary once knitr is supporting custom urls
hook_plot_html_wrapper <- function(custom_url, ...){
  function(x, options) {
    a = options$fig.align
    sprintf('<img src="%s" class="plot" %s/>\n', custom_url(x, ...),
          switch(a,
                 default = '',
                 left = 'style="float: left"',
                 right = 'style="float: right"',
                 center = 'style="margin: auto; display: block"'))
  }
}
#' define a wrapper to make a generic url image method markdown compatible
#' @param custom_url a function that uploads an image and returns a url
#' @param ... additional options for that function
#' @return a knitr hook for markdown format 
#' @details shouldn't be necessary once knitr is supporting custom urls
hook_plot_md_wrapper <- function(custom_url){
  function(x, options) {
    base = opts_knit$get('base.url')
    if (is.null(base)) base = ''
      sprintf('![plot of chunk %s](%s%s) ', options$label, base, custom_url(x))
  }
}



### Old perl-based uploader #####
## Flickr uploader method using my .flickr function (calls perl script)
flickr.id = function(x) {
  file = paste(x, collapse = '.')
  if (opts_knit$get('upload')) {
    flickr(file)
  } else file
}
## Flickr upload actually just calls a command line tool and returns the id code
flickr <- function(file, tags="", description="", public=TRUE){
  out <- system(paste('flickr_upload --tag="', tags, 
               ' " --description="', description, '"', ' --public ', 
               as.integer(public), file), intern=TRUE)
  gsub(".*ids=(\\d+)", "\\1", out[3])
}
## Create a hook that inserts my wordpress shortcode
hook_plot_flickr_shortcode_perl = function(x, options) {
    sprintf('[flickr]%s[/flickr]', .flickr.id(x))
}


