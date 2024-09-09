import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { sumNumbers } from "./utils";

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  const sumOf10And20 = sumNumbers(10, 20);
  return {
    statusCode: 200,
    body: JSON.stringify({ message: `sum of two numbers: ${sumOf10And20}` }),
  };
};
