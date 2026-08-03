# golang:1.22.5  
# setup workdir 
# copy requirement.txt and run it 
# copy source code to the docker image 
# run the project 

# take distroless image 
# copy the main file from the base stage 
# copy the static files to store into ./static
# expose the port
# run the project 

# Build the image 
# run the image 
# push the docker image to registry 

# Stage 1: Build the Go application
FROM golang:1.22.5 as base

WORKDIR /app

COPY go.mod .

COPY . .

RUN go build -o main .

# Stage 2: Create a minimal image with the compiled binary
FROM gcr.io/distroless/base

COPY --from=base /app/main .
COPY --from=base ./app/static ./static

EXPOSE 8080

CMD ["./main"]



