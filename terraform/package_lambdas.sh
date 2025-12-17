#!/bin/bash
# Package Lambda functions with dependencies

echo "================================================"
echo "Packaging Lambda Functions"
echo "================================================"
echo ""

FUNCTIONS=("create_user" "get_users" "polly_tts" "comprehend_sentiment")

for func in "${FUNCTIONS[@]}"
do
    echo "Packaging $func..."
    cd lambda_functions/$func
    
    # Create a temporary directory for packaging
    mkdir -p package
    
    # Install dependencies to package directory
    pip3 install -r requirements.txt -t package/ --quiet
    
    # Copy lambda function to package directory
    cp lambda_function.py package/
    
    # Create zip file
    cd package
    zip -r ../../${func}.zip . > /dev/null
    cd ..
    
    # Clean up
    rm -rf package
    
    cd ../..
    
    echo "✓ ${func}.zip created"
done

echo ""
echo "================================================"
echo "All Lambda functions packaged successfully!"
echo "================================================"
