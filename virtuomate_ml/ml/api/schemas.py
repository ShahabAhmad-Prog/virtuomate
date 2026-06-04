"""Pydantic schemas for Intelligence Engine API."""

from __future__ import annotations

from typing import Optional

from pydantic import BaseModel, Field


class AnalyzeTextRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=8000)
    session_type: str = Field(default="Conversation", max_length=64)
    context: Optional[str] = Field(default=None, max_length=2000)


class CoachingAssessmentResponse(BaseModel):
    confidence_score: int
    clarity_score: int
    professionalism_score: int
    anxiety_score: int
    communication_score: int
    interview_readiness_score: int
    emotion: str
    strengths: list[str]
    weaknesses: list[str]
    recommendations: list[str]
    provider: str
    transcript: str = ""
    speaking_pace_wpm: Optional[float] = None
    pause_frequency: Optional[float] = None
