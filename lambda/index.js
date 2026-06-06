exports.handler = async (event) => {
  console.log('Event received:', JSON.stringify(event, null, 2));
  
  for (const record of event.Records) {
    const filename = record.s3.object.key;
    console.log('Image received: ' + filename);
  }

  return {
    statusCode: 200,
    body: 'Processing complete'
  };
};
