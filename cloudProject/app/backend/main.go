package main

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"os"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"go.elastic.co/apm/module/apmgin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"

	_ "voting-platform/docs"

	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

// MongoDB client instance
var client *mongo.Client

// Database and collections names
const (
	dbName            = "voting_platform"
	optionsCollection = "options"
	votesCollection   = "votes"
)

// Option represents a voting option
type Option struct {
	ID       primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	Name     string             `json:"name" bson:"name"`
	SvgColor string             `json:"svgColor" bson:"svg_color"`
}

// VoteCount represents the vote count for an option
type VoteCount struct {
	ID       primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	OptionID primitive.ObjectID `json:"optionId" bson:"option_id"`
	Count    int                `json:"count" bson:"count"`
}

// VoteRequest represents the request body for voting
type VoteRequest struct {
	OptionID string `json:"optionId" binding:"required"`
}

// SuccessResponse is a generic success response structure
type SuccessResponse struct {
	Status  string `json:"status"`
	Message string `json:"message"`
}

// ErrorResponse is a generic error response structure
type ErrorResponse struct {
	Status  string `json:"status"`
	Message string `json:"message"`
}

// Result represents the response structure for voting results
type Result struct {
	ID       primitive.ObjectID `json:"id" bson:"_id"`
	Name     string             `json:"name" bson:"name"`
	Votes    int                `json:"votes" bson:"votes"`
	SvgColor string             `json:"svgColor" bson:"svg_color"`
}

// @title           Voting Platform API
// @version         1.0
// @description     API for a real-time voting platform
// @termsOfService  http://swagger.io/terms/

// @contact.name   API Support
// @contact.url    http://www.example.com/support
// @contact.email  support@example.com

// @license.name  Apache 2.0
// @license.url   http://www.apache.org/licenses/LICENSE-2.0.html

// @host      localhost:8080
// @BasePath  /api/v1

// @securityDefinitions.basic  BasicAuth
func main() {
	// Initialize MongoDB connection
	if err := initMongoDB(); err != nil {
		log.Fatalf("Failed to connect to MongoDB: %v", err)
	}
	defer func() {
		if err := client.Disconnect(context.Background()); err != nil {
			log.Fatalf("Failed to disconnect from MongoDB: %v", err)
		}
	}()

	// Set up Gin router
	r := gin.Default()

	// Enable CORS
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// Use APM middleware if APM_SERVER_URL is set
	if os.Getenv("APM_SERVER_URL") != "" {
		r.Use(apmgin.Middleware(r))
	}

	// API v1 routes
	v1 := r.Group("/api/v1")
	{
		// Health check endpoint
		v1.GET("/health", healthCheck)

		// Initialize data endpoint
		v1.POST("/init-data", initializeData)

		// Get all options endpoint
		v1.GET("/options", getAllOptions)

		// Vote for an option endpoint
		v1.POST("/vote", voteForOption)

		v1.GET("/results", getVotingResults)
	}

	// Swagger documentation
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("Server starting on port %s...\n", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

// Initialize MongoDB connection
func initMongoDB() error {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	// Get MongoDB connection string
	mongoURI := os.Getenv("MONGODB_URI")
	if mongoURI == "" {
		mongoURI = "mongodb://localhost:27017"
	}

	// Set client options
	clientOptions := options.Client().ApplyURI(mongoURI)

	// Connect to MongoDB
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var err error
	client, err = mongo.Connect(ctx, clientOptions)
	if err != nil {
		return err
	}

	// Ping the MongoDB server to verify connection
	if err = client.Ping(ctx, readpref.Primary()); err != nil {
		return err
	}

	log.Println("Successfully connected to MongoDB")
	return nil
}

// Generate a random pastel blue color
func generatePastelBlueColor() string {
	// Generate random values for green and blue channels
	r := 110 + rand.Intn(70) // 110-180
	g := 170 + rand.Intn(50) // 170-220
	b := 230 + rand.Intn(25) // 230-255

	return fmt.Sprintf("#%02x%02x%02x", r, g, b)
}

// @Summary Health check endpoint
// @Description Check if the API is running
// @Tags health
// @Produce json
// @Success 200 {object} SuccessResponse
// @Router /health [get]
func healthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, SuccessResponse{
		Status:  "success",
		Message: "API is running",
	})
}

// @Summary Initialize test data
// @Description Create test voting options and reset vote counts
// @Tags admin
// @Produce json
// @Success 200 {object} SuccessResponse
// @Failure 500 {object} ErrorResponse
// @Router /init-data [post]
func initializeData(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Get database and collections
	db := client.Database(dbName)
	optionsColl := db.Collection(optionsCollection)
	votesColl := db.Collection(votesCollection)

	// Drop existing collections to start fresh
	if err := optionsColl.Drop(ctx); err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Status:  "error",
			Message: fmt.Sprintf("Failed to drop options collection: %v", err),
		})
		return
	}

	if err := votesColl.Drop(ctx); err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Status:  "error",
			Message: fmt.Sprintf("Failed to drop votes collection: %v", err),
		})
		return
	}

	// Define options
	options := []interface{}{
		Option{Name: "Opción 1", SvgColor: generatePastelBlueColor()},
		Option{Name: "Opción 2", SvgColor: generatePastelBlueColor()},
		Option{Name: "Opción 3", SvgColor: generatePastelBlueColor()},
		Option{Name: "Opción 4", SvgColor: generatePastelBlueColor()},
		Option{Name: "Opción 5", SvgColor: generatePastelBlueColor()},
		Option{Name: "Opción 6", SvgColor: generatePastelBlueColor()},
		Option{Name: "Opción 7", SvgColor: generatePastelBlueColor()},
		Option{Name: "Opción 8", SvgColor: generatePastelBlueColor()},
	}

	// Insert options
	result, err := optionsColl.InsertMany(ctx, options)
	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Status:  "error",
			Message: fmt.Sprintf("Failed to insert options: %v", err),
		})
		return
	}

	// Create vote counts with zero for each option
	var voteCounts []interface{}
	for _, id := range result.InsertedIDs {
		optionID, ok := id.(primitive.ObjectID)
		if !ok {
			log.Printf("Warning: Could not convert ID to ObjectID: %v", id)
			continue
		}

		voteCounts = append(voteCounts, VoteCount{
			OptionID: optionID,
			Count:    0,
		})
	}

	// Insert vote counts
	if len(voteCounts) > 0 {
		_, err = votesColl.InsertMany(ctx, voteCounts)
		if err != nil {
			c.JSON(http.StatusInternalServerError, ErrorResponse{
				Status:  "error",
				Message: fmt.Sprintf("Failed to initialize vote counts: %v", err),
			})
			return
		}
	}

	c.JSON(http.StatusOK, SuccessResponse{
		Status:  "success",
		Message: fmt.Sprintf("Successfully initialized %d options with vote counts", len(options)),
	})
}

// @Summary Get all options
// @Description Retrieve all available voting options
// @Tags options
// @Produce json
// @Success 200 {array} Option
// @Failure 500 {object} ErrorResponse
// @Router /options [get]
func getAllOptions(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Get options collection
	optionsColl := client.Database(dbName).Collection(optionsCollection)

	// Find all options
	cursor, err := optionsColl.Find(ctx, bson.M{})
	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Status:  "error",
			Message: fmt.Sprintf("Failed to retrieve options: %v", err),
		})
		return
	}
	defer cursor.Close(ctx)

	// Decode options
	var options []Option
	if err := cursor.All(ctx, &options); err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Status:  "error",
			Message: fmt.Sprintf("Failed to decode options: %v", err),
		})
		return
	}

	c.JSON(http.StatusOK, options)
}

// @Summary Vote for an option
// @Description Increment the vote count for a specific option
// @Tags votes
// @Accept json
// @Produce json
// @Param voteRequest body VoteRequest true "Option ID to vote for"
// @Success 200 {object} SuccessResponse
// @Failure 400 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Failure 500 {object} ErrorResponse
// @Router /vote [post]
func voteForOption(c *gin.Context) {
	var request VoteRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{
			Status:  "error",
			Message: "Invalid request format",
		})
		return
	}

	// Convert string ID to ObjectID
	optionID, err := primitive.ObjectIDFromHex(request.OptionID)
	if err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{
			Status:  "error",
			Message: "Invalid option ID format",
		})
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Get collections
	optionsColl := client.Database(dbName).Collection(optionsCollection)
	votesColl := client.Database(dbName).Collection(votesCollection)

	// Check if option exists
	var option Option
	err = optionsColl.FindOne(ctx, bson.M{"_id": optionID}).Decode(&option)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, ErrorResponse{
				Status:  "error",
				Message: "Option not found",
			})
		} else {
			c.JSON(http.StatusInternalServerError, ErrorResponse{
				Status:  "error",
				Message: fmt.Sprintf("Failed to verify option: %v", err),
			})
		}
		return
	}

	// Update vote count
	result, err := votesColl.UpdateOne(
		ctx,
		bson.M{"option_id": optionID},
		bson.M{"$inc": bson.M{"count": 1}},
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Status:  "error",
			Message: fmt.Sprintf("Failed to update vote count: %v", err),
		})
		return
	}

	if result.MatchedCount == 0 {
		// If no document was matched, create a new vote count
		_, err = votesColl.InsertOne(ctx, VoteCount{
			OptionID: optionID,
			Count:    1,
		})
		if err != nil {
			c.JSON(http.StatusInternalServerError, ErrorResponse{
				Status:  "error",
				Message: fmt.Sprintf("Failed to create new vote count: %v", err),
			})
			return
		}
	}

	c.JSON(http.StatusOK, SuccessResponse{
		Status:  "success",
		Message: "Vote recorded successfully",
	})
}

// @Summary Get voting results
// @Description Retrieve the total votes for each option
// @Tags results
// @Produce json
// @Success 200 {array} Result
// @Failure 500 {object} ErrorResponse
// @Router /results [get]
func getVotingResults(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Get collections
	optionsColl := client.Database(dbName).Collection(optionsCollection)
	votesColl := client.Database(dbName).Collection(votesCollection)

	// Fetch all options
	cursor, err := optionsColl.Find(ctx, bson.M{})
	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Status:  "error",
			Message: fmt.Sprintf("Failed to retrieve options: %v", err),
		})
		return
	}
	defer cursor.Close(ctx)

	// Map to hold results
	var results []Result
	var options []Option
	if err := cursor.All(ctx, &options); err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Status:  "error",
			Message: fmt.Sprintf("Failed to decode options: %v", err),
		})
		return
	}

	// Fetch vote counts
	for _, option := range options {
		var voteCount VoteCount
		err := votesColl.FindOne(ctx, bson.M{"option_id": option.ID}).Decode(&voteCount)
		if err != nil {
			voteCount.Count = 0 // Default to zero if not found
		}
		results = append(results, Result{
			ID:       option.ID,
			Name:     option.Name,
			Votes:    voteCount.Count,
			SvgColor: option.SvgColor,
		})
	}

	c.JSON(http.StatusOK, results)
}
