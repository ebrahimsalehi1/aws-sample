import { SNSEvent, APIGatewayProxyResult } from "aws-lambda";
import { sumNumbers } from "./utils";

export const handler = async (
  event: SNSEvent
): Promise<APIGatewayProxyResult> => {
  const sumOf10And20 = sumNumbers(10, 20);

  console.log("EBI sns Records", JSON.stringify(event.Records));

  return {
    statusCode: 200,
    body: JSON.stringify({
      sum: sumOf10And20,
      now: new Date().toISOString(),
      snsRecords: JSON.stringify(event.Records),
    }),
  };
};
