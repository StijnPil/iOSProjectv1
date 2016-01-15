enum Error: ErrorType
{
    case InvalidJsonData(message: String?)
    case MissingJsonProperty(name: String)
    case MissingResponseData
    case NetworkError(message: String?)
    case UnexpectedStatusCode(code: Int)
}