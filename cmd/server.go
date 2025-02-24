package cmd

import (
	"fmt"
	"log"

	"github.com/spf13/cobra"
	"github.com/valyala/fasthttp"
)

var (
	port      int
	serverCmd = &cobra.Command{
		Use:   "server",
		Short: "Start the HTTP server",
		Long:  `Start the fasthttp server on the specified port`,
		Run: func(cmd *cobra.Command, args []string) {
			startServer()
		},
	}
)

func init() {
	rootCmd.AddCommand(serverCmd)
	serverCmd.Flags().IntVarP(&port, "port", "p", 8080, "Port to run the server on")
}

func startServer() {
	addr := fmt.Sprintf(":%d", port)

	// Create request handler
	requestHandler := func(ctx *fasthttp.RequestCtx) {
		switch string(ctx.Path()) {
		case "/":
			log.Printf("Received request to /")
			ctx.SetContentType("text/plain")
			welcomeMsg := fmt.Sprintf("Welcome to kbot server!\nVersion: %s", appVersion)
			ctx.WriteString(welcomeMsg)
		case "/health":
			log.Printf("Received request to /health")
			ctx.SetContentType("application/json")
			ctx.WriteString(`{"status": "ok"}`)
		default:
			log.Printf("Received request to %s", ctx.Path())
			ctx.WriteString(`{"error": "Not found"}`)
		}
	}

	server := &fasthttp.Server{
		Handler: requestHandler,
		Name:    "kbot",
	}

	log.Printf("Starting server on %s", addr)
	if err := server.ListenAndServe(addr); err != nil {
		log.Fatalf("Error starting server: %v", err)
	}
}
