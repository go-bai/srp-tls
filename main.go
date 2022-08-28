package main

import (
	"flag"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"strings"

	"github.com/gin-gonic/autotls"
	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/acme/autocert"
)

var proxyServer string
var domain string
var domains []string

func proxy(c *gin.Context) {
	remote, err := url.Parse(proxyServer)
	if err != nil {
		panic(err)
	}

	proxy := httputil.NewSingleHostReverseProxy(remote)
	proxy.Director = func(req *http.Request) {
		req.Header = c.Request.Header
		req.Host = remote.Host
		req.URL.Scheme = remote.Scheme
		req.URL.Host = remote.Host
		req.URL.Path = c.Param("proxyPath")
	}

	proxy.ServeHTTP(c.Writer, c.Request)
}

func init() {
	flag.StringVar(&proxyServer, "s", "", "代理服务器")
	flag.StringVar(&domain, "d", "", "域名")
	flag.Parse()

	if len(proxyServer) == 0 || len(domain) == 0 {
		log.Fatal("代理服务器和域名不能为空")
	}
	domains = strings.Split(domain, ",")
}

func main() {
	r := gin.Default()
	r.Any("/*proxyPath", proxy)

	m := autocert.Manager{
		Prompt:     autocert.AcceptTOS,
		HostPolicy: autocert.HostWhitelist(domains...),
		Cache:      autocert.DirCache("certs"),
	}

	log.Fatal(autotls.RunWithManager(r, &m))
}
