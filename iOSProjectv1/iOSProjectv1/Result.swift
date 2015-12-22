enum Result<T>
{
    case Success(T)
    case Failure(Service.Error)
}