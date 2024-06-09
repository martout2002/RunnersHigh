from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

class RecommendationRequest(BaseModel):
    user_history: str
    goal: str

@app.post("/recommendation/")
async def get_recommendation(request: RecommendationRequest):
    try:
        user_history = request.user_history
        goal = request.goal
        recommendation = "This is a dummy recommendation based on user history and goal"
        return {"recommendation": recommendation}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/list_files/")
async def list_files():
    try:
        files_list = []
        for dirname, _, filenames in os.walk('/kaggle/input/llama-3/pytorch/70b/1'):
            for filename in filenames:
                files_list.append(os.path.join(dirname, filename))
        return {"files": files_list}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
